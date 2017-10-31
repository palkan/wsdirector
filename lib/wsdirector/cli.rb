# frozen_string_literal: true

require "optparse"

require "wsdirector"
require "wsdirector/scenario_reader"
require "wsdirector/runner"

module WSDirector
  # Command line interface for WsDirector
  class CLI
    def initialize; end

    def run
      parse_args!

      scenario = WSDirector::ScenarioReader.parse(
        WSDirector.config.scenario_path
      )

      WSDirector::Runner.new(scenario).start
      exit 0
    rescue Error => e
      STDERR.puts e.message
      exit 1
    end

    private

    def parse_args!
      # rubocop: disable Metrics/LineLength
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wsdirector scenario_path ws_url [options]"

        opts.on("-s SCALE", "--scale=SCALE", Integer, "Scale factor") do |v|
          WSDirector.config.scale = v
        end

        opts.on("-t TIMEOUT", "--timeout=TIMEOUT", Integer, "Synchronization (wait_all) timeout") do |v|
          WSDirector.config.sync_timeout = v
        end

        opts.on("-c COLOR", "--color=COLOR", TrueClass, "Colorize output") do |v|
          WSDirector.config.colorize = v
        end
      end
      # rubocop: enable Metrics/LineLength

      parser.parse!

      WSDirector.config.scenario_path = ARGV[0]
      WSDirector.config.ws_url = ARGV[1]

      raise(Error, "Scenario path is missing") if WSDirector.config.scenario_path.nil?

      raise(Error, "File doesn't exist #{WSDirector.config.scenario_path}") unless
        File.file?(WSDirector.config.scenario_path)

      raise(Error, "Websocket server url is missing") if WSDirector.config.ws_url.nil?
    end
  end
end
