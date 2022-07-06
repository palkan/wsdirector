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

    def initialize(scenario, sync_timeout: 5)
      @scenario = scenario
      @total_count = scenario["total"]
      @global_holder = ClientsHolder.new(total_count, sync_timeout: sync_timeout)
      @results_holder = ResultsHolder.new
    end

    def execute(url:, scale: 1)
      Thread.abort_on_exception = true

      tasks = scenario["clients"].flat_map do |client|
        result = Result.new(client.fetch("name"))
        results_holder << result

        Array.new(client.fetch("multiplier")) do
          Thread.new do
            Task.new(client.deep_dup, global_holder: global_holder, result: result, scale: scale)
              .run(url)
          end
        end
      end

      tasks.each(&:join)

      results_holder
    end

    private

    attr_reader :scenario, :total_count, :global_holder, :results_holder, :scale
  end
end
