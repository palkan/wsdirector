# frozen_string_literal: true

require "wsdirector/scenario_reader"
require "wsdirector/clients_holder"
require "wsdirector/results_holder"
require "wsdirector/result"
require "wsdirector/task"
require "wsdirector/ext/deep_dup"

module WSDirector
  def self.run(scenario, scale: 1, connection_options: {}, **options)
    scenario = ScenarioReader.parse(scenario, scale:, connection_options:)
    Runner.new(scenario, scale:, **options).execute
  end

  # Initiates all clients as a separate tasks (=threads)
  class Runner
    using WSDirector::Ext::DeepDup

    def initialize(scenario, url:, scale: 1, sync_timeout: 5, logger: nil, colorize: false)
      @scenario = scenario
      @url = url
      @scale = scale
      @logger = logger
      @colorize = colorize
      @total_count = scenario["total"]
      @global_holder = ClientsHolder.new(total_count, sync_timeout:)
      @results_holder = ResultsHolder.new
    end

    def execute
      Thread.abort_on_exception = true

      num = 0

      tasks = scenario["clients"].flat_map do |client_config|
        name = client_config.fetch("name")
        result = Result.new(name)
        results_holder << result

        Array.new(client_config.fetch("multiplier")) do
          num += 1
          id = "#{name}_#{num}"
          Thread.new do
            Task.new(client_config.deep_dup, id:, colorize:, global_holder:, result:, scale:, logger:)
              .run(url)
          end
        end
      end

      tasks.each(&:join)

      results_holder
    end

    private

    attr_reader :scenario, :url, :scale, :total_count, :global_holder, :results_holder, :logger, :colorize
  end
end
