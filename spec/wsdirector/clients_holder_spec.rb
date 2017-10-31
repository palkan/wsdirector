describe WSDirector::ClientsHolder do
  let(:clients_count) { 3 }

  subject { described_class.new(clients_count) }

  describe "#wait_all" do
    it "loop untill all clients finish current task" do
      (clients_count - 1).times do
        Thread.new do
          expect(subject.wait_all).to be_truthy
        end
      end
      expect(subject.wait_all).to be_truthy
    end

    it "fails when not enough clients finish their work in time" do
      WSDirector.config.sync_timeout = 1

      (clients_count - 2).times do
        Thread.new do
          subject.wait_all
        end
      end

      expect { subject.wait_all }.to raise_error(
        WSDirector::Error,
        "Timeout (1s) exceeded for #wait_all"
      )
    end

    it "is re-usable" do
      threads = []

      clients_count.times do
        threads << Thread.new do
          expect(subject.wait_all).to be_truthy
        end
      end

      threads.map(&:join)

      (clients_count - 1).times do
        Thread.new do
          expect(subject.wait_all).to be_truthy
        end
      end
      expect(subject.wait_all).to be_truthy
    end
  end
end
