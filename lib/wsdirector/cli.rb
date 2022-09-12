# frozen_string_literal: true

require "optparse"
require "uri"

require "wsdirector"

module WSDirector
  # Command line interface for WsDirector
  class CLI
    class Configuration
      attr_accessor :ws_url, :scenario_path, :colorize, :scale,
        :sync_timeout, :json_scenario, :subprotocol, :verbose

      def initialize
        reset!
      end

      def colorize?
        colorize == true
      end

      # Restore to defaults
      def reset!
        @scale = 1
        @colorize = $stdout.tty?
        @sync_timeout = 5
      end
    end

    attr_reader :config

    def run
      @config = Configuration.new

      parse_args!

      begin
        require "colorize" if config.colorize?
      rescue LoadError
        config.colorize = false
        warn "Install colorize to use colored output"
      end

      connection_options = {
        subprotocol: config.subprotocol
      }.compact

      scenario = WSDirector::ScenarioReader.parse(
        config.scenario_path || config.json_scenario,
        scale: config.scale,
        connection_options: connection_options
      )

      logger = $stdout if config.verbose

      result = WSDirector::Runner.new(
        scenario,
        sync_timeout: config.sync_timeout,
        logger: logger,
        colorize: config.colorize
      ).execute(url: config.ws_url, scale: config.scale)

      puts "\n\n" if config.verbose

      result.print_summary(colorize: config.colorize?)
      result.success? || exit(1)
    end

    private

    FILE_FORMAT = /.+.(json|yml)\z/.freeze
    private_constant :FILE_FORMAT

    def parse_args!
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: wsdirector scenario_path ws_url [options]"

        opts.on("-s SCALE", "--scale=SCALE", Integer, "Scale factor") do |v|
          config.scale = v
        end

        opts.on("-t TIMEOUT", "--timeout=TIMEOUT", Integer, "Synchronization (wait_all) timeout") do |v|
          config.sync_timeout = v
        end

        opts.on("-i JSON", "--include=JSON", String, "Include JSON to parse") do |v|
          config.json_scenario = v
        end

        opts.on("-u URL", "--url=URL", Object, "Websocket server URL") do |v|
          config.ws_url = v
        end

        opts.on("-f PATH", "--file=PATH", String, "Scenario path") do |v|
          config.scenario_path = v
        end

        opts.on("--subprotocol=VALUE", String, "WebSocket subprotocol") do |v|
          config.subprotocol = v
        end

        opts.on("-c", "--[no-]color", "Colorize output") do |v|
          config.colorize = v
        end

        opts.on("-v", "--version", "Print version") do
          $stdout.puts WSDirector::VERSION
          exit 0
        end

        opts.on("-vv", "Print verbose logs") do
          config.verbose = true
        end
      end

      parser.parse!

      unless config.scenario_path
        config.scenario_path = ARGV.grep(FILE_FORMAT).last
      end

      unless config.ws_url
        config.ws_url = ARGV.grep(URI::DEFAULT_PARSER.make_regexp).last
      end

      check_for_errors
    end

    def check_for_errors
      if config.json_scenario.nil?
        raise(Error, "Scenario is missing") unless config.scenario_path

        unless File.file?(config.scenario_path)
          raise(Error, "File doesn't exist # config.scenario_path}")
        end
      end

      raise(Error, "Websocket server url is missing") unless config.ws_url
    end
  end
end
