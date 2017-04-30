require "spec_helper"

describe WSdirector::Task do
  subject { WSdirector::Task }

  let(:ws_addr) { 'ws://localhost:9876' }

  describe '#run' do

  end

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
      subject.start(test_script, ws_addr)
    end

    context 'when there is no script file' do
      it 'create new instance of WSdirector::Task? only with ws_addr' do
        expect(subject).to receive(:new).with(ws_addr)
        subject.start(ws_addr)
      end
    end

    context 'when script file exist, then create new instance of WSdirector::Task' do
      context 'when WSdirector::Configuration.load success' do
        it 'create new instance of WSdirector::Task' do
          allow(WSdirector::Configuration).to receive(:load).with(test_script).and_return(parsed_script)
          expect(subject).to receive(:new).with(parsed_script, ws_addr)
          subject.start(test_script, ws_addr)
        end
      end
    end
  end
end
