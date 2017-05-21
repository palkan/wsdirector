require "spec_helper"

describe WSdirector::Task do
  subject { WSdirector::Task }

  let(:ws_addr) { 'ws://localhost:9876' }
  let(:clients) { 10 }
  let(:test_script) { 'test.yml' }
  let(:clients_holder) { instance_double(WSdirector::ClientsHolder) }
  let(:results_holder) { instance_double(WSdirector::ResultsHolder) }


  let(:parsed_script) do
    [
      [:command],
      [:send_receive, { 'data' => { 'message' => 'we_send_it' } }, { 'data' => { 'message' => 'we wanna receive it' } }]
    ]
  end

  let(:parsed_single_script) do
    { 'group' => 'default', 'actions' => parsed_script }
  end

  let(:parsed_miltiple_script) do
    [
      { 'group' => '1', 'multiplier' => 10, 'actions' => parsed_script },
      { 'group' => '2', 'multiplier' => 100, 'actions' => parsed_script }
    ]
  end


  describe '.start' do
    it 'call start_cmd_ws when only ws_addr presence' do
      expect(subject).to receive_message_chain(:new, :start_cmd_ws).with(ws_addr).with(no_args)
      subject.start(ws_addr)
    end
    it 'call start_one_client, when only ws_addr and test_script presence' do
      expect(subject).to receive_message_chain(:new, :start_one_client).with(ws_addr, test_script).with(no_args)
      subject.start(ws_addr, test_script)
    end
    it 'call start_multiple_clients, when all params presence' do
      expect(subject).to receive_message_chain(:new, :start_multiple_clients).with(ws_addr, test_script, clients).with(no_args)
      subject.start(ws_addr, test_script, clients)
    end
  end

  describe '#start_one_client' do
    let(:task_example) { subject.new(ws_addr, test_script) }
    before(:example) do
      allow(WSdirector::Configuration).to receive(:parse).and_return(parsed_single_script)
      allow(task_example).to receive(:run_client)
      allow(WSdirector::ClientsHolder).to receive(:new).and_return(clients_holder)
      allow(WSdirector::ResultsHolder).to receive(:new).and_return(results_holder)
      allow(clients_holder).to receive(:wait_for_finish)
      allow(results_holder).to receive(:print_result)
    end
    after(:example) { task_example.send :start_one_client }

    it 'call Configuration.parse' do
      expect(WSdirector::Configuration).to receive(:parse).with(test_script)
    end

    it 'create new instance of ClientsHolder' do
      expect(WSdirector::ClientsHolder).to receive(:new)
    end

    it 'create new instance of ResultsHolder' do
      expect(WSdirector::ResultsHolder).to receive(:new)
    end

    it 'start srctipt with params' do
      expect(task_example).to receive(:run_client).with(parsed_single_script, clients_holder, results_holder)
    end

    it 'wait for clients_holder finish' do
      expect(clients_holder).to receive(:wait_for_finish)
    end

    it 'call print_result for clients_holder' do
      expect(results_holder).to receive(:print_result)
    end
  end

  describe '#start_multiple_clients' do
    let(:task_example) { subject.new(ws_addr, test_script, clients) }

    before(:example) do
      allow(WSdirector::Configuration).to receive(:multiple_parse).and_return(parsed_miltiple_script)
      allow(WSdirector::ClientsHolder).to receive(:new).and_return(clients_holder)
      allow(WSdirector::ResultsHolder).to receive(:new).and_return(results_holder)
      allow(task_example).to receive(:run_client)
      allow(clients_holder).to receive(:wait_for_finish)
      allow(results_holder).to receive(:print_result)
    end
    after(:example) { task_example.send :start_multiple_clients }

    it 'call Configuration.multiple_parse with number of multiplier_coefficient' do
      expect(WSdirector::Configuration).to receive(:multiple_parse).with(clients)
    end

    it 'create new instance of ClientsHolder' do
      expect(WSdirector::ClientsHolder).to receive(:new)
    end

    it 'create new instance of ResultsHolder' do
      expect(WSdirector::ResultsHolder).to receive(:new)
    end

    context 'with first clients params' do
      it 'call run_client 10 times with spec params' do
        expect(task_example).to receive(:run_client).with(parsed_miltiple_script[0], clients_holder, results_holder)
                                                    .exactly(10).times
      end
    end

    context 'with second client params' do
      it 'call run_client 100 times with spec params' do
        expect(task_example).to receive(:run_client).with(parsed_miltiple_script[1], clients_holder, results_holder)
                                                    .exactly(100).times
      end
    end

    it 'wait for clients_holder finish' do
      expect(clients_holder).to receive(:wait_for_finish)
    end

    it 'call print_result for clients_holder' do
      expect(results_holder).to receive(:print_result)
    end
  end

  describe '#run_client' do
    let(:task_example) { subject.new(ws_addr, test_script) }
    let(:client) { instance_double(WSdirector::Client) }
    let(:result) { instance_double(WSdirector::Result) }
    let(:websocket) { instance_double(WSdirector::Websocket) }

    before(:example) do
      allow(Thread).to receive(:new).and_yield
      allow(WSdirector::Client).to receive(:new).and_return(client)
      allow(clients_holder).to receive(:<<)
      allow(WSdirector::Result).to receive(:new).and_return(result)
      allow(results_holder).to receive(:<<)
      allow(WSdirector::Websocket).to receive(:new).and_return(websocket)
      allow(client).to receive(:start)
    end
    after(:example) { task_example.send :run_client, parsed_single_script, clients_holder, results_holder }
    it 'start new Thread' do
      expect(Thread).to receive(:new)
    end
    it 'create new instance of Client' do
      expect(WSdirector::Client).to receive(:new).with(parsed_single_script, websocket, result, parsed_single_script['group'])
    end
    it 'add client instance to clients_holder' do
      expect(clients_holder).to receive(:<<).with(client)
    end
    it 'create new instance of Result' do
      expect(WSdirector::Result).to receive(:new).with(parsed_single_script['group'])
    end
    it 'add result to results holder' do
      expect(results_holder).to receive(:<<).with(result)
    end
    it 'create instance of Websocket' do
      expect(WSdirector::Websocket).to receive(:new).with(ws_addr)
    end
    it 'start client with params' do
      expect(client).to receive(:start)
    end
  end
end
