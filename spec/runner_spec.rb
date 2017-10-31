# frozen_string_literal: true

require "spec_helper"

describe WsDirector::Runner do
  before(:all) do
    Thread.new { EchoServer.start }
  end

  it "execute success on simple echo scenario" do
    file_path = FixtureHelper.simple_scenario_path
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
  it "execute success on multi client broadcast scenario" do
    file_path = FixtureHelper.multi_client_scenario_path
    scenario = WsDirector::ScenarioReader.new(file_path, 3).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
end
