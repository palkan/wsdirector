require "spec_helper"

describe WSdirector::Result do
  let(:result) { WSdirector::Result.new("default") }

  it "has group" do
    expect(result.group).to eq("default")
  end

  it "has result_array" do
    expect(result.result_array).to eq([])
  end

  it "has summary_result" do
    expect(result.summary_result).to eq(all: 0, success: 0, fails: 0)
  end
  let(:send_command) { [:send_receive, { "data" => { "message" => "we_send_it" } }] }
  let(:receive_array) { [:receive, "data" => { "type" => "receive_something" }] }
  let(:expected_array) { [:receive, "data" => { "type" => "receive_something" }] }

  describe "#add_result_from_receive" do
    it "increas all count in summary result" do
      result.add_result_from_receive(receive_array, expected_array)
      expect(result.summary_result[:all]).to eq(1)
    end
    context "when command success" do
      it "assigns result to result_array" do
        result.add_result_from_receive(receive_array, expected_array)
        expect(result.result_array.last).to eq([true, nil, receive_array, expected_array])
      end

      it "increas success count in summary result" do
        result.add_result_from_receive(receive_array, expected_array)
        expect(result.summary_result[:success]).to eq(1)
      end
    end
    context "when command fails" do
      let(:expected_array) { [:receive, "data" => { "type" => "receive_something_else" }] }

      it "assigns result to result_array" do
        result.add_result_from_receive(receive_array, expected_array)
        expect(result.result_array.last).to eq([false, nil, receive_array, expected_array])
      end

      it "increase fails count in summary result" do
        result.add_result_from_receive(receive_array, expected_array)
        expect(result.summary_result[:fails]).to eq(1)
      end
    end
  end

  describe "#add_result_from_send_receive" do
    it "increas all count in summary result" do
      result.add_result_from_send_receive(send_command, receive_array, expected_array)
      expect(result.summary_result[:all]).to eq(1)
    end
    context "when command success" do
      it "assigns result to result_array" do
        result.add_result_from_send_receive(send_command, receive_array, expected_array)
        expect(result.result_array.last).to eq([true, send_command, receive_array, expected_array])
      end

      it "increas success count in summary result" do
        result.add_result_from_send_receive(send_command, receive_array, expected_array)
        expect(result.summary_result[:success]).to eq(1)
      end
    end
    context "when command fails" do
      let(:expected_array) { [:receive, "data" => { "type" => "receive_something_else" }] }

      it "assigns result to result_array" do
        result.add_result_from_send_receive(send_command, receive_array, expected_array)
        expect(result.result_array.last).to eq([false, send_command, receive_array, expected_array])
      end

      it "increase fails count in summary result" do
        result.add_result_from_send_receive(send_command, receive_array, expected_array)
        expect(result.summary_result[:fails]).to eq(1)
      end
    end
  end
end
