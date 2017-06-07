module WSdirector
  class ResultsHolder

    attr_accessor :groups

    def initialize
      @groups = {}
    end

    def print_result
      groups.each do |group, results|
        group_result = results.all? { |result| result.summary_result[:fails] == 0 }
        if group_result
          Printer.out("Group #{group} - all messages success", :green)
        else
          print_fails(group, results)
        end
      end
    end

    def print_fails(group, results)
      bad = results.select { |r| r.result_array.any? { |i| i[0] == false } }
      Printer.out("Group #{group} fails", :red)
      Printer.out("- #{bad.size} clients of #{results.size} fails", :red)
      bad.first.result_array.select { |i| i[0] == false }.each do |row|
        Printer.out(
          "-- send: #{row[1]}\n--expect receive: #{row[3]}\n--got: #{row[2]}",
          :red
        )
      end
    end

    def <<(result)
      groups[result.group] ||= []
      groups[result.group] << result
    end
  end
end
