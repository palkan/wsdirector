require "spec_helper"

describe WSdirector::ScriptInterpreter do
  subject { WSdirector::ScriptInterpreter }

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

  describe '#run'
end
