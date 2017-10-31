# frozen_string_literal: true

require "wsdirector/printer"

module WSDirector
  # Holds all results for all groups of clients
  class ResultsHolder
    def initialize
      @groups = Concurrent::Map.new
    end

    def print_summary
      single_group = groups.size == 1
      groups.each do |group, result|
        color = result.success? ? :green : :red
        prefix = single_group ? "" : "Group #{group}: "
        Printer.out(
          "#{prefix}#{result.total_count} clients, #{result.failures_count} failures\n",
          color
        )

        print_errors(result.errors) unless result.success?
      end
    end

    def <<(result)
      groups[result.group] = result
    end

    private

    attr_reader :groups

    def print_errors(errors)
      errors.each do |error|
        Printer.out "-- #{error}\n", :red
      end
    end
  end
end
