module WsDirector
  class Client
    require 'websocket-client-simple'
    require 'json'

    def initialize(path, scenario, threads_count = 1)
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @threads_count = threads_count
      @current_waited = 0
      threads = threads_count.times.map do |i|
        Thread.new{process(path, scenario, i)}
      end
      threads.each(&:join)
    end

    def process(path, scenario, thread_num)
      queue = scenario.clone
      ws = WebSocket::Client::Simple.connect path
      ws.on :message do |msg|
        task = queue.first
        next unless task
        if task['data'].to_json == msg.data
          task = queue.shift
          #p "#{thread_num} received #{task}"
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
      end
      while(!ws.open?)
        p "[#{thread_num}] not opened"
      end
      while(ws.open? && !queue.empty?)
        #p "[#{thread_num}] next_instruction"
        # p "[#{thread_num}] #{queue}"

        if queue.first && queue.first['type'] == 'wait_all'
          @mutex.synchronize do
            p "#{thread_num} wait"
            @current_waited += 1
            if @threads_count == @current_waited
              p 'free'
              @resource.broadcast
            else
              @resource.wait(@mutex)
            end
          end
          queue.shift
        end
        if queue.first && queue.first['type'] == 'send'
          ws.send(queue.shift['data'].to_json)
          # p "[#{thread_num}]: sended :#{queue.shift['data'].to_json}"
        end
      end
    end
  end
end
