require "spec_helper"

describe WSdirector::ScriptInterpreter do
  subject { WSdirector::ScriptInterpreter }

  describe '.start' do
    it "create new instance of #{subject}" do
      ws = instance_double("WebSocket::Client::Simple")
      script = []
      expect(subject).to receive(:new).with(ws, script)
      subject.start(ws, script)
    end
    it 'start script'
  end
end
