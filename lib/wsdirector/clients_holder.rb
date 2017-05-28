module WSdirector
  class ClientsHolder

    attr_accessor :all_cnt, :clients_wait, :clients_finished_work

    def initialize(cnt = [1])
      @all_cnt = cnt.inject(:+)
      @clients_wait = 0
      @clients_finished_work = 0
    end

    def wait_for_finish
      while all_cnt > clients_finished_work;end
      clients_finished_work
    end

    def wait_all
      @clients_wait += 1
      while all_cnt > clients_wait;end
      clients_wait
    end

    def <<(client)
      client.register(self)
    end

    def finish_work
      @clients_finished_work += 1
    end
  end
end
