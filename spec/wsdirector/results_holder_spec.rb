# frozen_string_literal: true

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
    before { allow(WSDirector::Printer).to receive(:out) }

    context "when no failures" do
      it "call print success message for every group" do
        subject << success
        subject.print_summary
        expect(WSDirector::Printer).to have_received(:out).with("3 clients, 0 failures\n", :green)
      end
    end

    context "when failures" do
      it "call print failure message for every group", :aggregate_failures do
        subject << success
        subject << failure
        subject.print_summary
        expect(WSDirector::Printer).to have_received(:out).with("Group group_1: 3 clients, 0 failures\n", :green)
        expect(WSDirector::Printer).to have_received(:out).with("Group group_2: 4 clients, 2 failures\n", :red)
        expect(WSDirector::Printer).to have_received(:out).with("1) Incorrect message\n", :red)
        expect(WSDirector::Printer).to have_received(:out).with("2) Timeout error\n", :red)
      end
    end
  end
end
