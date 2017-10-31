describe WSDirector::ResultsHolder do
  subject { described_class.new }

  let(:success) do
    WSDirector::Result.new("group_1").tap do |res|
      3.times { res.succeed }
    end
  end

  let(:failure) do
    WSDirector::Result.new("group_2").tap do |res|
      2.times { res.succeed }
      res.failed "Incorrect message"
      res.failed "Timeout error"
    end
  end

  describe "#print_summary" do
    context "when no failures" do
      it "call print success message for every group" do
        subject << success
        expect(WSDirector::Printer).to receive(:out).with("3 clients, 0 failures\n", :green)
        subject.print_summary
      end
    end

    context "when failures" do
      it "call print failure message for every group", :aggregate_failures do
        subject << success
        subject << failure
        expect(WSDirector::Printer).to receive(:out).with("Group group_1: 3 clients, 0 failures\n", :green)
        expect(WSDirector::Printer).to receive(:out).with("Group group_2: 4 clients, 2 failures\n", :red)
        expect(WSDirector::Printer).to receive(:out).with("-- Incorrect message\n", :red)
        expect(WSDirector::Printer).to receive(:out).with("-- Timeout error\n", :red)
        subject.print_summary
      end
    end
  end
end
