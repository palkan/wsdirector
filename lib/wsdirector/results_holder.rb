# frozen_string_literal: true

module WSDirector
  # Holds all results for all groups of clients
  class ResultsHolder
    def initialize
      @groups = Concurrent::Map.new
    end

    def success?
      @groups.values.all?(&:success?)
    end

    def print_summary(printer: $stdout, colorize: false)
      single_group = groups.size == 1

      groups.each do |group, result|
        color = result.success? ? :green : :red
        prefix = single_group ? "" : "Group #{group}: "

        msg = "#{prefix}#{result.total_count} clients, #{result.failures_count} failures\n"
        msg = msg.colorize(color) if colorize

        printer.puts(msg)

        unless result.success?
          print_errors(result.errors, printer: printer, colorize: colorize)
          printer.puts "\n"
        end
      end
    end

    def <<(result)
      groups[result.group] = result
    end

    private

    attr_reader :groups

    def print_errors(errors, printer:, colorize:)
      printer.puts "\n"

      errors.each.with_index do |error, i|
        msg = "#{i + 1}) #{error}\n"
        msg = msg.colorize(:red) if colorize

        printer.puts msg
      end
    end
  end
end
