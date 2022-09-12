# frozen_string_literal: true

require "wsdirector/clients_holder"
require "wsdirector/results_holder"
require "wsdirector/result"
require "wsdirector/task"
require "wsdirector/ext/deep_dup"

module WSDirector
  # Initiates all clients as a separate tasks (=threads)
  class Runner
    using WSDirector::Ext::DeepDup

    def initialize(scenario, sync_timeout: 5, logger: nil, colorize: false)
      @scenario = scenario
      @logger = logger
      @colorize = colorize
      @total_count = scenario["total"]
      @global_holder = ClientsHolder.new(total_count, sync_timeout:)
      @results_holder = ResultsHolder.new
    end

    def execute(url:, scale: 1)
      Thread.abort_on_exception = true

      num = 0

      tasks = scenario["clients"].flat_map do |client|
        name = client.fetch("name")
        result = Result.new(name)
        results_holder << result

        Array.new(client.fetch("multiplier")) do
          num += 1
          id = "#{name}_#{num}"
          Thread.new do
            Task.new(client.deep_dup, id:, colorize:, global_holder:, result:, scale:, logger:)
              .run(url)
          end
        end
      end

      tasks.each(&:join)

      results_holder
    end

    private

    attr_reader :scenario, :total_count, :global_holder, :results_holder, :scale, :logger, :colorize
  end
end
