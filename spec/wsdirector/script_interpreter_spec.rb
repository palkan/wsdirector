require "spec_helper"

describe WSdirector::ScriptInterpreter do
  subject { WSdirector::ScriptInterpreter }

  let(:scrpt) do
    [
      { 'receive' => { 'data' => { 'message' => 1 } } },
      { 'send' => { 'data' => { 'message' => 2 } } },
      { 'receive' => { 'data' => { 'message' => 3 } } },
      { 'send' => { 'data' => { 'message' => 4 } } }
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
      allow(script_interpreter).to receive(:set_message_endpoint)
      allow(script_interpreter).to receive(:sleep)
      expect(script_interpreter).to receive(:send_to_ws).exactly(2).times
      script_interpreter.send(:recursive_parse, scrpt)
      script_interpreter.send(:start_sending_loop)
    end

    it 'assign key in @work_hash where to send messages from WebSocket' do
      allow(script_interpreter).to receive(:send_to_ws)
      allow(script_interpreter).to receive(:sleep)
      expect(script_interpreter).to receive(:set_message_endpoint).exactly(2).times
      script_interpreter.send(:recursive_parse, scrpt)
      script_interpreter.send(:start_sending_loop)
    end

    it 'sleep 1 sec after each send' do
      allow(script_interpreter).to receive(:send_to_ws)
      allow(script_interpreter).to receive(:set_message_endpoint)
      expect(script_interpreter).to receive(:sleep).with(1).exactly(2).times
      script_interpreter.send(:recursive_parse, scrpt)
      script_interpreter.send(:start_sending_loop)
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

  describe '#recursive_parse' do
    context 'when send first' do
      it 'assign expected hash to @expected_hash' do
        # expected_send_receive = {
        #   'default'=>[{"data"=>1}],
        #   "{\"data\"=>2}" => [{"data"=>3}],
        #   "{\"data\"=>4}" => []
        # }
        expected_send_receive = {
          'default'=>[{"message"=>1}],
          "{\"message\"=>2}" => [{"message"=>3}],
          "{\"message\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.expected_hash).to eq(expected_send_receive)
      end

      it 'assign work hash to @work_hash' do
        work_send_receive = {
          'default'=>[],
          "{\"message\"=>2}" => [],
          "{\"message\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.work_hash).to eq(work_send_receive)
      end
    end

    context 'when receive first' do
      before(:example) { scrpt.shift }
      it 'assign expected hash to @expected_hash' do
        expected_send_receive = {
          "{\"message\"=>2}" => [{ "message"=>3}],
          "{\"message\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.expected_hash).to eq(expected_send_receive)
      end

      it 'assign work hash to @work_hash' do
        work_send_receive = {
          "{\"message\"=>2}" => [],
          "{\"message\"=>4}" => []
        }
        script_interpreter.send(:recursive_parse, scrpt)
        expect(script_interpreter.work_hash).to eq(work_send_receive)
      end
    end
  end
end
