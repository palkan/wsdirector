# frozen_string_literal: true

module WSDirector
  # Acts as a re-usable global barrier for a fixed number of clients.
  # Barrier is reset if sucessfully passed in time.
  class ClientsHolder
    def initialize(count)
      @barrier = Concurrent::CyclicBarrier.new(count)
    end

    def wait_all
      result = barrier.wait(WSDirector.config.sync_timeout)
      raise Error, "Timeout (#{WSDirector.config.sync_timeout}s) exceeded for #wait_all" unless
        result
      barrier.reset
      result
    end

    private

    attr_reader :barrier
  end
end
