require "wsdirector/version"
<<<<<<< HEAD
require "wsdirector/task"
=======
require "wsdirector/scenario_reader"
require "wsdirector/client"
require "wsdirector/runner"

module WsDirector
  def self.perform
    scenario = WsDirector::ScenarioReader.new(ARGV[0])
    WsDirector::Client.new(ARGV[1], scenario)
  end
end
>>>>>>> eaef55b... tmp version, tested with action cable
