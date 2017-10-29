require "spec_helper"

describe WSdirector::ResultsHolder do
  let(:results_holder) { WSdirector::ResultsHolder.new }

  let(:success_results) do
    [
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 })
    ]
  end

  let(:fail_results) do
    [
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 4, fails: 1 }),
      instance_double(WSdirector::Result, summary_result: { all: 5, success: 4, fails: 1 })
    ]
  end

  let(:success_summary_result) do
    [
      [true, "send_command5", "array5", "array5"],
      [true, "send_command4", "array4", "array4"],
      [true, "send_command1", "array1", "array1"],
      [true, "send_command2", "array2", "array2"],
      [true, "send_command6", "array6", "array6"]
    ]
  end

  let(:fail_summary_result) do
    [
      [true, "send_command5", "array5", "array5"],
      [true, "send_command4", "array4", "array4"],
      [true, "send_command1", "array1", "array1"],
      [true, "send_command2", "array2", "array2"],
      [false, "send_command3", "receive_array3", "expected_array3"]
    ]
  end

  it "has groups hash" do
    expect(results_holder.groups).to eq({})
  end

  describe "#<<" do
    it "add result instance to appropriate group" do
      result = instance_double(WSdirector::Result)
      allow(result).to receive(:group).and_return("default")
      results_holder << result
      expect(results_holder.groups["default"].last).to eq(result)
    end
  end

  describe "#print_result" do
    context "when there is no fails" do
      before(:example) do
        allow(results_holder).to receive(:groups) do
          {
            "default" => success_results
          }
        end
      end
      it "call print success message for every group" do
        expect(WSdirector::Printer).to receive(:out).with("Group default - all messages success", :green)
        results_holder.print_result
      end
    end

    context "when there is fails" do
      before(:example) do
        allow(results_holder).to receive(:groups) do
          {
            "default" => fail_results
          }
        end
      end
      it "call print_result with group and results" do
        expect(results_holder).to receive(:print_fails).with("default", fail_results)
        results_holder.print_result
      end
    end
  end

  describe "#print_fails" do
    let(:good_result) { instance_double(WSdirector::Result, summary_result: { all: 5, success: 5, fails: 0 }) }
    let(:bad_result) do
      instance_double(WSdirector::Result,
                      summary_result: { all: 5, success: 4, fails: 1 })
      # result_array: fail_summary_result
    end
    let(:fail_results) do
      [
        good_result,
        good_result,
        good_result,
        bad_result,
        bad_result
      ]
    end
    before(:example) do
      allow(good_result).to receive(:result_array).and_return(success_summary_result)
      allow(bad_result).to receive(:result_array).and_return(fail_summary_result)
    end
    it "print fail group and specific errors for first result" do
      expect(WSdirector::Printer).to receive(:out).with("Group default fails", :red)
      expect(WSdirector::Printer).to receive(:out).with("- 2 clients of 5 fails", :red)
      expect(WSdirector::Printer).to receive(:out).with("-- send: send_command3\n--expect receive: expected_array3\n--got: receive_array3", :red)
      results_holder.print_fails("default", fail_results)
    end
  end
end
