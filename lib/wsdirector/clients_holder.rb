require 'concurrent'

module WSdirector
  class ClientsHolder

    attr_accessor :all_cnt
    attr_accessor :barrier_for_finish, :barrier_for_task

    def initialize(cnt = [1])
      @all_cnt = cnt.inject(:+)
      @barrier_for_finish = Concurrent::CyclicBarrier.new(@all_cnt + 1)
      @barrier_for_task = Concurrent::CyclicBarrier.new(@all_cnt)
    end

    def wait_for_finish
      result = barrier_for_finish.wait
      barrier_for_finish.reset
      result
    end

    def wait_all
      result = barrier_for_task.wait(Configuration::TIMEOUT)
      raise 'Broken on timeout in client_holder.rb in wait_all' unless result
      barrier_for_task.reset
      result
    end

    def <<(client)
      client.register(self)
    end

    def finish_work
      result = barrier_for_finish.wait # (Configuration::TIMEOUT)
      abort("Broken on timeout in client_holder.rb in finish_work") unless result
    end
  end
end
