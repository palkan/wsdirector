# frozen_string_literal: true

require "wsdirector"
require "optparse"
require "wsdirector/scenario_reader"
require "wsdirector/client"
require "wsdirector/result"
require "wsdirector/clients_holder"
require "wsdirector/results_holder"
require "wsdirector/printer"

module WSDirector
  # Command line interface for WsDirector
  class CLI
    def initialize; end

    def run
      parse_args!

      scenario = WSDirector::ScenarioReader.parse(
        WSDirector.config.scenario_path
      )

      WSDirector::Runner.new(WSDirector.config.ws_url, scenario).start
      exit 0
    rescue Error => e
      STDERR.puts e.message
      exit 1
    end

    private

    def parse_args!
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wsdirector scenario_path ws_url [options]"

        opts.on("-s SCALE", "--scale=SCALE", Integer, "Scale") do |v|
          WSDirector.config.scale = v
        end

        opts.on("-c COLOR", "--color=COLOR", TrueClass, "Colorize output") do |v|
          WSDirector.config.colorize = v
        end
      end

      parser.parse!

      WSDirector.config.scenario_path = ARGV[0]
      WSDirector.config.ws_url = ARGV[1]

      raise(Error, "Scenario path is missing") if WSDirector.config.scenario_path.nil?

      raise(Error, "Websocket server url is missing") if WSDirector.config.ws_url.nil?
    end
  end
end
