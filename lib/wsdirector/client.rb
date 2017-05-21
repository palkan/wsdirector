module WSdirector
  class Client

    attr_accessor :clients_holder
    attr_accessor :script, :ws, :result, :group

    def initialize(script, ws, result, group)
      @group = group
      @script = script
      @ws = ws
      @result = result
    end

    def start
      script['actions'].each do |command|
        send command.shift, command
      end
    end

    private

    def wait_all(_)
      ticks = 0
      while clients_holder.wait_all
        ticks += 1
      end
      ticks
    end

    def receive(expected_array)
      receive_array = expected_array.map { |i| nil }
      receive_array = ws.receive(receive_array)
      result.add_result_from_receive(receive_array, expected_array)
    end
  end
end
