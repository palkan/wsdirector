# frozen_string_literal: true

require "wsdirector/clients_holder"
require "wsdirector/results_holder"
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

      tasks = scenario.map do |client|
        Task.new(client, global_holder: global_holder, results_holder: results_holder)
            .run
      end

      tasks.each(&:join)
      results_holder.print_summary
      true
    end

    private

    attr_reader :scenario, :total_count, :global_holder, :results_holder
  end
end
