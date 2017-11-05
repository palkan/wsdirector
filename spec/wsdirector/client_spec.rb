describe WSDirector::Client do
  context "with EchoServer" do
    before(:all) { Thread.new { EchoServer.start } }

    after(:all) { EchoServer.stop }

    subject { described_class.new }

    before { WSDirector.config.ws_url = EchoServer.url }

    describe "#initialize" do
      it "opens connection" do
        subject
        expect(subject.ws).to be_open
      end

      context "when url is wrong" do
        it "raises error" do
          WSDirector.config.ws_url = "ws://localhost:666"
          expect { subject }.to raise_error(WSDirector::Error, /failed to connect/i)
        end
      end
    end

    describe "#send / #receive" do
      specify do
        subject.send "test message"

        expect(subject.receive).to eq "test message"
      end
    end
  end

  context "with Cable server and ignore" do
    before(:all) { CableServer.start }
    after(:all) { CableServer.stop }

    before { WSDirector.config.ws_url = CableServer.url }

    subject { described_class.new(ignore: [/ping/]) }

    describe "#initialize" do
      it "receives welcome message" do
        subject
        expect(subject.ws).to be_open

        expect(subject.receive).to eq({ type: "welcome" }.to_json)
      end

      context "when ping is not ignored" do
        subject { described_class.new }

        it "receives ping message" do
          subject
          msgs = []
          msgs << subject.receive
          msgs << subject.receive

          expect(msgs).to include({ type: "welcome" }.to_json)
          expect(msgs).to include(/ping/)
        end
      end
    end

    describe "#send / #receive" do
      it "subscribes to channel" do
        subject
        expect(subject.receive).to eq({ type: "welcome" }.to_json)

        subject.send({ command: "subscribe", identifier: JSON.generate(channel: "chat", id: "22") }.to_json)
        expect(subject.receive).to eq({ "identifier" => "{\"channel\":\"chat\",\"id\":\"22\"}", "type" => "confirm_subscription" }.to_json)
      end
    end
  end
end
