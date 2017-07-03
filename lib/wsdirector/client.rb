module WsDirector
  class Client
    require 'websocket-client-simple'
    require 'json'
    attr_reader :path, :scenario, :wait_proc

    def initialize(path, scenario, wait_proc)
      @path = path
      @scenario = scenario
      @wait_proc = wait_proc
      @mutex = Mutex.new
    end

    def perform(threads_count = 1)
      threads = threads_count.times.map do |i|
        Thread.new { process(path, scenario, threads_count * 2 + i) }
      end
      threads.each(&:join)
    end

    def process(path, scenario, thread_num)
      queue = Marshal.load(Marshal.dump(scenario))
      messages = Queue.new
      ws = WebSocket::Client::Simple.connect path do |ws|
        ws.on :message do |msg|
          begin
            message = JSON.parse(msg.data)
            unless message["type"] == "ping"
              messages << message
            end
          rescue JSON::ParserError
            messages << msg.data
          end
        end

        ws.on :open do
        end

        ws.on :close do |e|
          exit 1
        end

        ws.on :error do |e|
          puts "-- error (#{e.inspect} #{e.backtrace})"
          exit 1
        end
      end
      while !ws.open?
      end
      wait_proc
      handle_instruction_from_queue(queue, thread_num, ws, messages)
    end

    def handle_instruction_from_queue(queue, thread_num, ws, messages)
      return if queue.empty?
      task = queue.shift
      if task['type'] == 'send'
        ws.send(task['data'].to_json)
      elsif task['type'] == 'wait_all'
        wait_proc.call
      elsif task['type'] == 'receive'
        message = receive_message(messages)
        if task['data'] == message
          task_multiplier = task['multiplier']
          if !task_multiplier.nil? && task_multiplier.to_i != 1
            task['multiplier'] = task_multiplier - 1
            queue.unshift(task)
          end
        else
          raise Exception.new("RECEIVED: #{message}  EXPECTED: #{task['data']}")
        end
      end
      handle_instruction_from_queue(queue, thread_num, ws, messages)
    end

    def receive_message(messages)
      messages.pop
    rescue
      nil
    end
  end
end
