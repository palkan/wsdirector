module WSdirector
  class Result
    attr_accessor :group, :result_array, :summary_result

    def initialize(group)
      @group = group
      @result_array = []
      @summary_result = { all: 0, success: 0, fails: 0 }
    end

    def add_result_from_receive(receive_array, expected_array)
      proccess_result(receive_array, expected_array)
    end

    def add_result_from_send_receive(send_command, receive_array, expected_array)
      proccess_result(send_command, receive_array, expected_array)
    end

    def proccess_result(command = nil, receive_array, expected_array)
      result = receive_array == expected_array
      result_array << [result, command, receive_array, expected_array]
      summary_result[:all] += 1
      result ? summary_result[:success] += 1 : summary_result[:fails] += 1
    end
  end
end
