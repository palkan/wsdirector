module WSdirector
  class ResultsHolder

    attr_accessor :groups

    def initialize
      @groups = {}
    end

    def print_result
      groups.each do |group, results|
        group_result = results.all? { |result| result.summary_result[:fails] == 0 }
        p "Group #{group} - all messages success" if group_result
      end
    end

    def <<(result)
      groups[result.group] ||= []
      groups[result.group] << result
    end
  end
end
