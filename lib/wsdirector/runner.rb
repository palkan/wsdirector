# frozen_string_literal: true

require "wsdirector/clients_holder"
require "wsdirector/results_holder"
require "wsdirector/result"
require "wsdirector/task"

module WsDirector
  # Initiates all clients as a separate tasks (=threads)
  class Runner
    def initialize(scenario)
      @scenario = scenario
      @total_count = scenario.sum { |client| client["total"] }
      @global_holder = ClientsHolder.new(total_count)
      @results_holder = ResultsHolder.new
    end

    def start
      Thread.abort_on_exception = true

      tasks = scenario.flat_map do |client|
        result = Result.new(client.fetch("name"))
        results_holder << result

        Array.new(client.fetch("multiplier")) do
          Thread.new do
            Task.new(client, global_holder: global_holder, result: result)
                .run
          end
        end
      end

      tasks.each(&:join)
      results_holder.print_summary
      true
    end

    private

    attr_reader :scenario, :total_count, :global_holder, :results_holder
  end
end
