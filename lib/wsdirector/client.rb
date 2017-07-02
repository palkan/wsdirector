module WsDirector
  class Client
    require 'websocket-client-simple'
    require 'json'
    require "concurrent"

    WAIT_WHEN_EXPECTING_EVENT = 5
    WAIT_WHEN_NOT_EXPECTING_EVENT = 0.5

    attr_reader :path, :scenario, :wait_proc

    def initialize(path, scenario, wait_proc)
      @path = path
      @scenario = scenario
      @wait_proc = wait_proc
      @messages = Queue.new
      @mutex = Mutex.new
      @has_messages = Concurrent::Semaphore.new(0)
    end

    def perform(threads_count = 1)
      threads = threads_count.times.map do |i|
        Thread.new { process(path, scenario, threads_count * 2 + i) }
      end
      threads.each(&:join)
    end

    def process(path, scenario, thread_num)
      queue = Concurrent::Array.new(Marshal.load(Marshal.dump(scenario)))
      messages = @messages
      has_messages = @has_messages
      ws = WebSocket::Client::Simple.connect path do |ws|
        ws.on :message do |msg|
          message = JSON.parse(msg.data)
          unless message["type"] == "ping"
            messages << message
            has_messages.release
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
      handle_instruction_from_queue(queue, thread_num, ws)
      p "#{thread_num} ended #{queue}"
    end

    def handle_instruction_from_queue(queue, thread_num, ws)
      return if queue.empty?
      sleep(0.5)
      task = queue.shift
      if task['type'] == 'send'
        ws.send(task['data'].to_json)
        sleep(0.5)
      elsif task['type'] == 'wait_all'
        wait_proc.call
      elsif task['type'] == 'receive'
        message = receive_message
        if task['data'] == message
          task_multiplier = task['multiplier']
          if !task_multiplier.nil? && task_multiplier.to_i != 1
            task['multiplier'] = task_multiplier - 1
            queue.unshift(task)
            p "#{thread_num}  ----"
          end
        else
          sleep(2)
          raise Exception.new("#{thread_num} ERROR #{message} && #{task['data']}") if @messages.empty?
        end
      end
      handle_instruction_from_queue(queue, thread_num, ws)
    end

    def receive_message
      @has_messages.try_acquire(1, WAIT_WHEN_EXPECTING_EVENT)
      @messages.pop(true)
    rescue
      nil
    end
  end
end
