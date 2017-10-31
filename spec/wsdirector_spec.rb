require "spec_helper"

describe WSdirector do
  let(:test_script) { "test_script.yml" }

  it "has a version number" do
    expect(WSdirector::VERSION).not_to be nil
  end

  describe "connect to websocket server" do
    context "when connection success" do
      it "shows success message"
    end
    context "when connection fails" do
      it "exit with non-zero code and show error log"
    end
  end

  it "execute success on simple echo scenario" do
    file_path = File.join(File.dirname(__dir__), "spec", "fixtures", "test_scenario.yml")
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
  it "execute success on multi client broadcast scenario" do
    file_path = File.join(File.dirname(__dir__), "spec", "fixtures", "test_multi_scenario.yml")
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
end
