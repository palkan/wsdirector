# frozen_string_literal: true

require "wsdirector/printer"

module WSDirector
  # Holds all results for all groups of clients
  class ResultsHolder
    def initialize
      @groups = Concurrent::Map.new
    end

    def success?
      @groups.values.all?(&:success?)
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

        unless result.success?
          print_errors(result.errors)
          Printer.out "\n"
        end
      end
    end

    def <<(result)
      groups[result.group] = result
    end

    private

    attr_reader :groups

    def print_errors(errors)
      Printer.out "\n"
      errors.each.with_index do |error, i|
        Printer.out "#{i + 1}) #{error}\n", :red
      end
    end
  end
end
