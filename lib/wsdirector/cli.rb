# frozen_string_literal: true

require "optparse"
require "uri"

require "wsdirector"
require "wsdirector/scenario_reader"
require "wsdirector/runner"

module WSDirector
  # Command line interface for WsDirector
  class CLI
    def initialize
    end

    def run
      parse_args!

      begin
        require "colorize" if WSDirector.config.colorize?
      rescue LoadError
        WSDirector.config.colorize = false
        warn "Install colorize to use colored output"
      end

      scenario = WSDirector::ScenarioReader.parse(
        WSDirector.config.scenario_path || WSDirector.config.json_scenario
      )

      if WSDirector::Runner.new(scenario).start
        exit 0
      else
        exit 1
      end
    rescue Error => e
      warn e.message
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

        opts.on("-i JSON", "--include=JSON", String, "Include JSON to parse") do |v|
          WSDirector.config.json_scenario = v
        end

        opts.on("-u URL", "--url=URL", Object, "Websocket server URL") do |v|
          WSDirector.config.ws_url = v
        end

        opts.on("-c", "--[no-]color", "Colorize output") do |v|
          WSDirector.config.colorize = v
        end

        opts.on("-v", "--version", "Print versin") do
          $stdout.puts WSDirector::VERSION
          exit 0
        end
      end
      # rubocop: enable Metrics/LineLength

      parser.parse!
      check_for_errors
    end

    def check_for_errors
      WSDirector.config.scenario_path = ARGV[0]

      if WSDirector.config.json_scenario.nil?
        raise(Error, "Scenario is missing") if WSDirector.config.scenario_path.nil?

        unless File.file?(WSDirector.config.scenario_path)
          raise(Error, "File doesn't exist #{WSDirector.config.scenario_path}")
        end
      end

      raise(Error, "Websocket server url is missing") if WSDirector.config.ws_url.nil?
      raise(Error, "Invalid websocket server url") unless WSDirector.config.ws_url.match?(URI::DEFAULT_PARSER.make_regexp)
    end
  end
end
