# frozen_string_literal: true

module WSDirector
  # Acts as a re-usable global barrier for a fixed number of clients.
  # Barrier is reset if sucessfully passed in time.
  class ClientsHolder
    def initialize(count, sync_timeout: 5)
      @barrier = Concurrent::CyclicBarrier.new(count)
      @sync_timeout = sync_timeout
    end

    def wait_all
      result = barrier.wait(sync_timeout)
      raise Error, "Timeout (#{sync_timeout}s) exceeded for #wait_all" unless
        result
      barrier.reset
      result
    end

    private

    attr_reader :barrier, :sync_timeout
  end
end
