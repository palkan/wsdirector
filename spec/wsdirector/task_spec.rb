require "spec_helper"

describe WSdirector::Task do
  subject { WSdirector::Task }

  describe ".start" do
    it "call WSdirector::Configuration.load" do
      expect(WSdirector::Configuration).to receive(:load).with
    end

    context "then create new instance of WSdirector::Task" do
      context "when WSdirector::Configuration.load success" do
        it "create new instance of WSdirector::Task"
      end

      context "when WSdirector::Configuration.load fails" do
        it "Exit with non-zero code and error stack"
      end
    end
  end
end
