# frozen_string_literal: true
require "websocket-client-simple"

module WSDirector
  class Client
    attr_reader :path, :scenario, :wait_proc

    def initialize(path, scenario, wait_proc)
      @path = path
      @scenario = scenario
      @wait_proc = wait_proc
    end

    def perform(threads_count = 1)
      threads = threads_count.times.map do |i|
        Thread.new { process(path, scenario, threads_count * 2 + i) }
      end
      threads.each(&:join)
    end

    def process(path, scenario, thread_num)
      queue = Marshal.load(Marshal.dump(scenario))
      ws = WebSocket::Client::Simple.connect path do |ws|
        ws.on :message do |msg|
          task = queue.first
          p "#{thread_num} RECEIVE  #{msg.data}"
          next unless task
          if task["data"].to_json == msg.data
            task_multiplier = task["multiplier"]
            if task_multiplier.nil? || task_multiplier.to_i == 1
              queue.shift
            else
              task["multiplier"] = task_multiplier - 1
              queue[0] = task
              p "#{thread_num}  ----"
            end
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
      until ws.open?
      end
      while ws.open? && !queue.empty?
        if queue.first && queue.first["type"] == "wait_all"
          queue.shift
          wait_proc.call
        end
        next unless queue.first && queue.first["type"] == "send"
        task = queue.shift
        p "#{thread_num} SEND #{task}"
        ws.send(task["data"].to_json)
      end
      p "#{thread_num} ended #{queue}"
    end
  end
end
