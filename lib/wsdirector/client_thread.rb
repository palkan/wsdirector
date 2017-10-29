module WsDirector
  class ClientThread
    require "websocket-client-simple"
    require "json"
    require "concurrent"

    attr_reader :wait_proc, :ws

    WAIT_WHEN_EXPECTING_RECEIVE = 5

    def initialize(path, scenario, wait_proc, thread_num)
      @wait_proc = wait_proc
      has_messages = @has_messages = Concurrent::Semaphore.new(0)
      scenario = Marshal.load(Marshal.dump(scenario))
      messages = @messages = Queue.new
      @ws = WebSocket::Client::Simple.connect path do |ws|
        ws.on :message do |msg|
          begin
            message = JSON.parse(msg.data)
            messages << message unless message["type"] == "ping"
          rescue JSON::ParserError
            messages << msg.data
          end
          has_messages.release
        end

        ws.on :error do |e|
          raise_exception("ERROR #{e.inspect} #{e.backtrace}")
        end
      end
      wait_connecting
      handle_instruction_from_scenario(scenario, thread_num)
    rescue Errno::ECONNREFUSED
      raise_exception("Can't connect to websocket")
    end

    def handle_instruction_from_scenario(scenario, thread_num)
      raise_exception("Connection was closed") unless ws.open?
      return if scenario.empty?
      task = scenario.shift
      if task["type"] == "send"
        ws.send(task["data"].to_json)
      elsif task["type"] == "wait_all"
        wait_proc.call
      elsif task["type"] == "receive"
        message = receive_message
        if task["data"] == message
          task_multiplier = task["multiplier"]
          if !task_multiplier.nil? && task_multiplier.to_i != 1
            task["multiplier"] = task_multiplier - 1
            scenario.unshift(task)
          end
          @retried = false
        else
          return raise_exception("#{thread_num} RECEIVED: #{message}  EXPECTED: #{task['data']}") if @retried
          scenario.unshift(task)
          @messages << message if message
          @has_messages.release
          @retried = true
          sleep(WAIT_WHEN_EXPECTING_RECEIVE)
          return handle_instruction_from_scenario(scenario, thread_num)
        end
      end
      handle_instruction_from_scenario(scenario, thread_num)
    end

    def receive_message
      @has_messages.try_acquire(1, WAIT_WHEN_EXPECTING_RECEIVE)
      @messages.pop(true)
    rescue
      nil
    end

    def raise_exception(message)
      raise(Exception, message)
    end

    def wait_connecting
      until ws.open?
      end
    end
  end
end
