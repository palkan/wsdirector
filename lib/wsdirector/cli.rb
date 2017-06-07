require "wsdirector"
require 'optparse'
require "wsdirector/task"
require "wsdirector/scenario_reader"
require "wsdirector/client"
require "wsdirector/result"
require "wsdirector/clients_holder"
require "wsdirector/results_holder"
require "wsdirector/printer"

module WsDirector
  class CLI
    def initialize(argv)
    end

    def run
      scenario = WsDirector::ScenarioReader.new(argv[0])
      WsDirector::Client.new(ARGV[1], scenario)
    end

    private

    def parse
      options = {}
      options[:file_path] = ARGV[0]
      options[:ws_path] = ARGV[1]

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wsdirector scenario_path ws_path [options]"

        opts.on("-s SCALE", "--scale=SCALE", "Scale") do |v|
          options[:scale] = v
        end
      end

      parser.parse!

      if options[:file_path].nil?
        raise(Error, 'Scenario path is missing')
      end

      if options[:ws_path].nil?
        raise(Error, 'Websocket server url is missing')
      end
    end
  end
end
