require "spec_helper"

describe WSdirector::ClientsHolder do
  let(:clients_holder) { WSdirector::ClientsHolder.new([2, 3]) }

  it 'set initial params' do
    expect(clients_holder.all_cnt).to eq(5)
  end

  describe '#<<' do
    it 'register self on client' do
      client = instance_double(WSdirector::Client)
      expect(client).to receive(:register).with(clients_holder)
      clients_holder << client
    end
    # it 'add client to relevant group'
  end

  describe '#wait_for_finish' do
    it 'loop untill all clients finished' do
      (clients_holder.all_cnt).times do
        Thread.new do
          expect(clients_holder.finish_work).to be_truthy
        end
      end
      expect(clients_holder.wait_for_finish).to be_truthy
    end

    it 'fails when not enough threads finished' do
      (clients_holder.all_cnt - 1).times do
        Thread.new do
          expect(clients_holder.finish_work).to be_truthy
        end
      end
      expect { clients_holder.wait_for_finish }.to raise_error('No live threads left. Deadlock?')
    end
  end

  describe '#wait_all' do
    before(:example) {
      # allow(WSdirector::Configuration).to receive(:TIMEOUT).and_return(5)
      WSdirector::Configuration::TIMEOUT = 5
    }
    after(:example) { WSdirector::Configuration::TIMEOUT = 30 }
    it 'loop untill all clients finish current task' do
      (clients_holder.all_cnt - 1).times do
        Thread.new do
          clients_holder.wait_all
        end
      end
      expect(clients_holder.wait_all).to be_truthy
    end
    it 'fails when not enough threads finished current task' do
      (clients_holder.all_cnt - 2).times do
        Thread.new do
          clients_holder.wait_all
        end
      end
      expect { clients_holder.wait_all }.to raise_error('Broken on timeout in client_holder.rb in wait_all')
    end
  end
end
