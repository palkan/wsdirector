require "spec_helper"

describe WSdirector::Client do
  let(:ws) { instance_double(WSdirector::Websocket) }
  let(:result) { instance_double(WSdirector::Result) }
  let(:clients_holder) { instance_double(WSdirector::ClientsHolder)}
  let(:group) { 'default' }

  let(:parsed_script) do
    [
      [:wait_all],
      [:receive, { 'data' => { 'message' => 'we wanna receive it' } }],
      [:send_receive, { 'data' => { 'message' => 'we_send_it' } }, { 'data' => { 'message' => 'we wanna receive it' } }]
    ]
  end

  let(:parsed_single_script) do
    { 'group' => 'default', 'actions' => parsed_script }
  end

  let(:client) { WSdirector::Client.new(parsed_single_script, ws, result, group) }

  describe '#start' do
    before(:example) do
      allow(client).to receive(:wait_all)
      allow(client).to receive(:receive)
      allow(client).to receive(:send_receive)
    end
    after(:example) { client.start }

    it 'call wait_all' do
      expect(client).to receive(:wait_all)
    end
    it 'call receive with receive params only' do
      expect(client).to receive(:receive).with([{ 'data' => { 'message' => 'we wanna receive it' } }])
    end
    it 'call send_receive with send and receive expecting' do
      expect(client).to receive(:send_receive).with([{ 'data' => { 'message' => 'we_send_it' } }, { 'data' => { 'message' => 'we wanna receive it' } }])
    end
  end

  describe '#wait_all' do
    it 'waits until clients_holder allow to continue' do
      client.clients_holder = clients_holder
      allow(clients_holder).to receive(:wait_all) do
        @ticks ||= 0
        @ticks += 1
        @ticks == 5 ? false : true
      end
      expect(client.send(:wait_all, [])).to eq(4)
    end
  end

  describe '#receive' do
    before(:example) do
      allow(ws).to receive(:receive).and_return([{ 'data' => { 'message' => 'we wanna receive it' } }])
      allow(result).to receive(:add_result_from_receive)
    end
    after(:example) { client.send :receive, [{ 'data' => { 'message' => 'we wanna receive it' } }]  }
    it 'call receive command on ws' do
      expect(ws).to receive(:receive).with([nil])
    end
    it 'assign result to instance of result' do
      expect(result).to receive(:add_result_from_receive)
                    .with([{ 'data' => { 'message' => 'we wanna receive it' } }],
                          [{ 'data' => { 'message' => 'we wanna receive it' } }])
    end
  end
end
