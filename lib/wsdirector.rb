require "wsdirector/version"
require "wsdirector/scenario_reader"
require "wsdirector/client"
require "wsdirector/client_thread"
require "wsdirector/runner"

module WsDirector
  def self.perform(scenario_path, ws_path, scale)
    scenario = WsDirector::ScenarioReader.new(scenario_path, scale).to_hash
    WsDirector::Runner.new(ws_path, scenario)
  end
end
