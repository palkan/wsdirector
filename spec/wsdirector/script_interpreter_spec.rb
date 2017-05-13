require "spec_helper"

describe WSdirector::ScriptInterpreter do
  subject { WSdirector::ScriptInterpreter }

  let(:scrpt) do
    [
      { 'receive' => { 'data' => 1 } },
      { 'send' => { 'data' => 2 } },
      { 'receive' => { 'data' => 3 } },
      { 'send' => { 'data' => 4 } }
    ]
  end

  let(:script_interpreter) { subject.new(nil, scrpt) }

  describe '.start' do
    let(:params) { [instance_double("Client"), []] }
    it 'create new instance' do
      inst = instance_double(subject)
      allow(inst).to receive(:run)
      expect(subject).to receive(:new).with(*params).and_return(inst)
      subject.start(*params)
    end
    it 'run script' do
      expect_any_instance_of(subject).to receive(:run)
      subject.start(*params)
    end
  end

  describe '#start_sending_loop' do
    it 'sends messaged to ws' do
      pending 'looks like wrong way'
      ws = instance_double("WebsocketClientSimple")
      allow(script_interpreter).to receive(:websocket).and_return(ws)
      expect(ws).to receive(:send).exactly(script_interpreter.send_commands.size).times
      script_interpreter.start_sending_loop
    end
  end

  describe '#run' do
    it 'call bunch of methods' do
      expect(script_interpreter).to receive(:init_connection)
      expect(script_interpreter).to receive(:recursive_parse).with(scrpt)
      expect(script_interpreter).to receive(:start_sending_loop)
      script_interpreter.run
    end
  end

  describe '#recursive_parse, scrpt' do
    let(:scrpt) do
      [
        { 'receive' => { 'data' => 1 } },
        { 'send' => { 'data' => 2 } },
        { 'receive' => { 'data' => 3 } },
        { 'send' => { 'data' => 4 } }
      ]
    end

    context 'when send first' do
      it 'assign expected hash to @expected_hash' do
        expected_send_receive = {
          'default'=>[{"data"=>1}],
          "{\"data\"=>2}" => [{"data"=>3}],
          "{\"data\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.expected_hash).to eq(expected_send_receive)
      end

      it 'assign work hash to @work_hash' do
        work_send_receive = {
          'default'=>[],
          "{\"data\"=>2}" => [],
          "{\"data\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.work_hash).to eq(work_send_receive)
      end
    end

    context 'when receive first' do
      before(:example) { scrpt.shift }
      it 'assign expected hash to @expected_hash' do
        expected_send_receive = {
          "{\"data\"=>2}" => [{ "data"=>3}],
          "{\"data\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.expected_hash).to eq(expected_send_receive)
      end

      it 'assign work hash to @work_hash' do
        work_send_receive = {
          "{\"data\"=>2}" => [],
          "{\"data\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.work_hash).to eq(work_send_receive)
      end
    end
  end
end
