require "spec_helper"

describe WSdirector::Task do
  subject { WSdirector::Task }

  let(:ws_addr) { 'ws://localhost:9876' }

  describe '.start' do
    let(:test_script) { 'test.yml' }
    let(:parsed_script) do
      [
        { first_step: 'to it'},
        { second_step: 'do nothing' }
      ]
    end

    it 'call WSdirector::Configuration.load' do
      expect(WSdirector::Configuration).to receive(:load).with(test_script).and_return(parsed_script)
      allow_any_instance_of(subject).to receive(:run_with_script)
      subject.start(test_script, ws_addr)
    end

    context 'when there is no script file' do
      it 'create new instance of WSdirector::Task only with ws_addr' do
        expect(subject).to receive(:new).with(ws_addr)
        subject.start(ws_addr)
      end
    end

    context 'when script file exist and WSdirector::Configuration.load success' do
      it 'create new instance of WSdirector::Task with ws_addr and script_yml' do
        allow(WSdirector::Configuration).to receive(:load).with(test_script).and_return(parsed_script)
        expect(subject).to receive(:new).with(parsed_script, ws_addr)
        subject.start(test_script, ws_addr)
      end
    end
  end
end
