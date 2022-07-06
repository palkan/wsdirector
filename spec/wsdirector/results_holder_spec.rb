# frozen_string_literal: true

require "colorize"

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
    let(:printer) { double }

    before { allow(printer).to receive(:puts) }

    context "when no failures" do
      it "call print success message for every group" do
        subject << success
        subject.print_summary(printer: printer, colorize: false)
        expect(printer).to have_received(:puts).with("3 clients, 0 failures\n")
      end
    end

    context "when failures" do
      it "call print failure message for every group", :aggregate_failures do
        subject << success
        subject << failure
        subject.print_summary(printer: printer, colorize: true)
        expect(printer).to have_received(:puts).with("Group group_1: 3 clients, 0 failures\n".colorize(:green))
        expect(printer).to have_received(:puts).with("Group group_2: 4 clients, 2 failures\n".colorize(:red))
        expect(printer).to have_received(:puts).with("1) Incorrect message\n".colorize(:red))
        expect(printer).to have_received(:puts).with("2) Timeout error\n".colorize(:red))
      end
    end
  end
end
