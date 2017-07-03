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
          message = JSON.parse(msg.data)
          unless message["type"] == "ping"
            messages << message
            p "#{thread_num} RECEIVE #{message}"
          end
        end

        ws.on :open do
          puts "-- websocket open (#{ws.url})"
        end

        ws.on :close do |e|
          puts "-- websocket close (#{e.inspect})"
          exit 1
        end

        ws.on :error do |e|
          puts "-- error (#{e.inspect} #{e.backtrace})"
          exit 1
        end
      end
      while !ws.open?
      end
      handle_instruction_from_queue(queue, thread_num, ws, messages)
      p "#{thread_num} ended #{queue}"
    end

    def handle_instruction_from_queue(queue, thread_num, ws, messages)
      raise Exception unless ws.open?
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
            p "#{thread_num}  ----"
          end
        else
          raise Exception.new("#{thread_num} ERROR #{message} new #{receive_message} && #{task['data']}") if messages.empty?
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
