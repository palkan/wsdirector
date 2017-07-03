require "wsdirector/version"
require "wsdirector/scenario_reader"
require "wsdirector/client"
require "wsdirector/client_thread"
require "wsdirector/runner"

module WsDirector
  def self.perform
    scenario = WsDirector::ScenarioReader.new(ARGV[0])
    WsDirector::Client.new(ARGV[1], scenario)
  end
end
