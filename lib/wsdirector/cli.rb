require "wsdirector"
require "wsdirector/task"
require "wsdirector/scenario_reader"
require "wsdirector/client"

module WsDirector
  class CLI
    def initialize(argv)
    end

    def run
      scenario = WsDirector::ScenarioReader.new(argv[0])
      WsDirector::Client.new(ARGV[1], scenario)
    end
  end
end
