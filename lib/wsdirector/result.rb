# frozen_string_literal: true

module WSDirector
  # Handle results from all clients from the group
  class Result
    attr_reader :group, :errors

    def initialize(group)
      @group = group
      @errors = Concurrent::Array.new

      @all = Concurrent::AtomicFixnum.new(0)
      @failures = Concurrent::AtomicFixnum.new(0)

      @sampling_mutex = Mutex.new
      @sampling_counter = Hash.new { |h, k| h[k] = 0 }
    end

    # Called when client successfully finished it's work
    def succeed
      all.increment
    end

    # Called when client failed
    def failed(error_message)
      errors << error_message
      all.increment
      failures.increment
    end

    def success?
      failures.value.zero?
    end

    def total_count
      all.value
    end

    def failures_count
      failures.value
    end

    def track_sample(id, max)
      sampling_mutex.synchronize do
        return false if sampling_counter[id] >= max

        sampling_counter[id] += 1
        true
      end
    end

    private

    attr_reader :all, :success, :failures, :sampling_counter, :sampling_mutex
  end
end
