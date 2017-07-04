module WsDirector
  class Client
    attr_reader :path, :scenario, :wait_proc

    def initialize(path, scenario, wait_proc)
      @path = path
      @scenario = scenario
      @wait_proc = wait_proc
    end

    def perform(threads_count = 1)
      threads = Array.new(threads_count) do |i|
        Thread.new do
          WsDirector::ClientThread.new(path, scenario, wait_proc, i)
        end
      end
      threads.each(&:join)
    end
  end
end
