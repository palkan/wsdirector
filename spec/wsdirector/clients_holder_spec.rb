require "spec_helper"

describe WSdirector::ClientsHolder do
  let(:clients_holder) { WSdirector::ClientsHolder.new([2, 3]) }

  it 'set initial params' do
    expect(clients_holder.all_cnt).to eq(5)
    expect(clients_holder.clients_wait).to eq(0)
    expect(clients_holder.clients_finished_work).to eq(0)
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
      fake_clients_finish = 0
      allow(clients_holder).to receive(:clients_finished_work) do
        fake_clients_finish += 1
      end
      expect(clients_holder.wait_for_finish).to eq(5 + 1) # :) because of last statement
    end
  end

  describe '#wait_all' do
    it 'add +1 to clients_wait' do
      clients_holder.all_cnt = 1
      expect(clients_holder.wait_all).to eq(1)
    end
    it 'loop untill all clients finish current task' do
      fake_clients_finish = 0
      allow(clients_holder).to receive(:clients_wait) do
        fake_clients_finish += 1
      end
      expect(clients_holder.wait_all).to eq(5 + 1) # :) because of last statement
    end
  end

  describe '#finish work' do
    it 'add +1 clients_finished_work' do
      clients_holder.finish_work
      clients_holder.finish_work
      expect(clients_holder.clients_finished_work).to eq(2)
    end
  end
end
