# frozen_string_literal: true

require "optparse"
require "uri"

require "wsdirector"
require "wsdirector/scenario_reader"
require "wsdirector/runner"

module WSDirector
  # Command line interface for WsDirector
  class CLI
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

    FILE_FORMAT = /.+.(json|yml)\z/.freeze
    private_constant :FILE_FORMAT

    def parse_args!
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

      WSDirector.config.scenario_path = ARGV.grep(FILE_FORMAT).last

      unless WSDirector.config.ws_url
        WSDirector.config.ws_url = ARGV.grep(URI::DEFAULT_PARSER.make_regexp).last
      end

      check_for_errors
    end

    def check_for_errors
      if WSDirector.config.json_scenario.nil?
        raise(Error, "Scenario is missing") unless WSDirector.config.scenario_path

        unless File.file?(WSDirector.config.scenario_path)
          raise(Error, "File doesn't exist #{WSDirector.config.scenario_path}")
        end
      end

      raise(Error, "Websocket server url is missing") unless WSDirector.config.ws_url
    end
  end
end
