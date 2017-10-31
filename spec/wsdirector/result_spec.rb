describe WSDirector::Result do
  subject { described_class.new("default") }

  specify "group" do
    expect(subject.group).to eq("default")
  end

  specify "errors" do
    expect(subject.errors).to be_a(Concurrent::Array)
  end

  describe "#succeed" do
    it "increments totals" do
      threads = []
      3.times do
        threads << Thread.new { subject.succeed }
      end

      threads.each(&:join)

      expect(subject.errors.size).to eq 0
      expect(subject.total_count).to eq 3
      expect(subject.failures_count).to eq 0
    end
  end

  describe "#failed" do
    it "adds errors and increments totals", :aggregate_failures do
      threads = []
      3.times do
        threads << Thread.new { subject.failed("Unknown error") }
      end

      threads.each(&:join)

      expect(subject.errors.size).to eq 3
      expect(subject.errors.last)
        .to match(/Unknown error/)
      expect(subject.total_count).to eq 3
      expect(subject.failures_count).to eq 3
    end
  end
end
