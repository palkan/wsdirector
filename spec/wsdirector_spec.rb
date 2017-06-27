require "spec_helper"

describe WsDirector do
  before(:all) do
    Thread.new { EchoServer.start }
  end
  it 'has a version number' do
    expect(WsDirector::VERSION).not_to be nil
  end

  it 'does something useful' do
    file_path = File.join(File.dirname(__dir__), 'spec', 'fixtures', 'test_scenario.yml')
    scenario = WsDirector::ScenarioReader.new(file_path).to_hash
    WsDirector::Client.new('ws://127.0.0.1:3000/websocket', scenario)
    # WsDirector::Client.new(EchoServer.url, scenario)
  end
end
