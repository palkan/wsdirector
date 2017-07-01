require "spec_helper"

describe WsDirector do
  before(:all) do
    Thread.new { EchoServer.start }
  end
  it 'has a version number' do
    expect(WsDirector::VERSION).not_to be nil
  end

  it 'execute success on simple echo scenario' do
    file_path = File.join(File.dirname(__dir__), 'spec', 'fixtures', 'test_scenario.yml')
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
  it 'execute success on multi client broadcast scenario' do
    file_path = File.join(File.dirname(__dir__), 'spec', 'fixtures', 'test_multi_scenario.yml')
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Runner.new(EchoServer.url, scenario)
  end
end
