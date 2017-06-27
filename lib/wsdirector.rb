require "wsdirector/version"
require "wsdirector/scenario_reader"
require "wsdirector/client"

module WsDirector
  def self.perform
    scenario = WsDirector::ScenarioReader.new(ARGV[0])
    WsDirector::Client.new(ARGV[1], scenario)
  end
end
