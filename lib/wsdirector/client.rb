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

    def register(clients_holder)
      @clients_holder = clients_holder
    end

    def start
      ws.init
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

    def send_receive(expected_array)
      send_command = expected_array.shift
      receive_array = expected_array.map { |i| nil }
      receive_array = ws.send_receive(send_command, receive_array)
      result.add_result_from_send_receive(send_command, expected_array, receive_array)
    end
  end
end
