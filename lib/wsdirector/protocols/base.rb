# frozen_string_literal: true

require "time"
require "wsdirector/ext/formatting"

module WSDirector
  module Protocols
    using Ext::Formatting

    using(Module.new do
      refine ::Object do
        def matches?(other)
          self == other
        end

        def partially_matches?(other)
          self == other
        end
      end

      refine ::Array do
        def matches?(actual)
          if actual.is_a?(::String)
            actual = JSON.parse(actual) rescue nil # rubocop:disable Style/RescueModifier
          end

          return false unless actual

          each.with_index do
            return false unless _1.matches?(actual[_2])
          end

          true
        end

        def partially_matches?(actual)
          if actual.is_a?(::String)
            actual = JSON.parse(actual) rescue nil # rubocop:disable Style/RescueModifier
          end

          return false unless actual

          each.with_index do
            return false unless _1.partially_matches?(actual[_2])
          end

          true
        end
      end

      refine ::Hash do
        def matches?(actual)
          unless actual.is_a?(::Hash)
            actual = JSON.parse(actual) rescue nil # rubocop:disable Style/RescueModifier
          end

          return false unless actual

          actual.each_key do
            return false unless actual[_1].matches?(self[_1])
          end

          true
        end

        def partially_matches?(actual)
          unless actual.is_a?(::Hash)
            actual = JSON.parse(actual) rescue nil # rubocop:disable Style/RescueModifier
          end

          return false unless actual

          each_key do
            return false unless self[_1].partially_matches?(actual[_1])
          end

          true
        end
      end
    end)

    class PartialMatcher
      attr_reader :obj

      def initialize(obj)
        @obj = obj
      end

      def matches?(actual)
        obj.partially_matches?(actual)
      end

      def inspect
        "an object including #{obj.inspect}"
      end

      def truncate(...) = obj.truncate(...)
    end

    # Base protocol describes basic actions
    class Base
      class ReceiveTimeoutError < StandardError
      end

      include WSDirector::Utils

      def initialize(task, scale: 1, logger: nil, id: nil, color: nil)
        @task = task
        @scale = scale
        @logger = logger
        @id = id
        @color = color
      end

      def init_client(...)
        log { "Connecting" }

        @client = build_client(...)

        log(:done) { "Connected" }
      end

      def handle_step(step)
        type = step.delete("type")
        raise Error, "Unknown step: #{type}" unless respond_to?(type)

        return unless task.sampled?(step)

        public_send(type, step)
      end

      # Sleeps for a specified number of seconds.
      #
      # If "shift" is provided than the initial value is
      # shifted by random number from (-shift, shift).
      #
      # Set "debug" to true to print the delay time.
      def sleep(step)
        delay = step.fetch("time").to_f
        shift = step.fetch("shift", 0).to_f

        delay = delay - shift * rand + shift * rand

        log { "Sleep for #{delay}s" }

        Kernel.sleep delay if delay > 0

        log(:done) { "Slept for #{delay}s" }
      end

      # Prints provided message
      def debug(step)
        with_logger do
          log(nil) { step.fetch("message") }
        end
      end

      def receive(step)
        expected = step["data"] || PartialMatcher.new(step["data>"])
        ordered = step["ordered"]
        timeout = step.fetch("timeout", 5).to_f

        log { "Receive a message in #{timeout}s: #{expected.truncate(100)}" }

        start = Time.now.to_f
        received = nil

        client.each_message do |msg, id|
          received = msg
          if expected.matches?(msg)
            client.consumed(id)
            break
          end

          if ordered
            raise UnmatchedExpectationError, prepare_receive_error(expected, received)
          end

          if Time.now.to_f - start > timeout
            raise ReceiveTimeoutError
          end
        end

        log(:done) { "Received a message: #{received&.truncate(100)}" }
      rescue ThreadError, ReceiveTimeoutError
        if received
          raise UnmatchedExpectationError, prepare_receive_error(expected, received)
        else
          raise NoMessageError, "Expected to receive #{expected} but nothing has been received"
        end
      end

      def receive_all(step)
        messages = step.delete("messages")
        raise ArgumentError, "Messages array must be specified" if
          messages.nil? || messages.empty?

        expected =
          messages.map do |msg|
            multiplier = parse_multiplier(msg.delete("multiplier") || "1")
            [msg["data"] || PartialMatcher.new(msg["data>"]), multiplier]
          end.to_h

        total_expected = expected.values.sum
        total_received = 0

        log { "Receive #{total_expected} messages" }

        total_expected.times do
          received = client.receive

          total_received += 1

          match = expected.find { |k, _| k.matches?(received) }

          raise UnexpectedMessageError, "Unexpected message received: #{received}" if
            match.nil?

          expected[match.first] -= 1
          expected.delete(match.first) if expected[match.first].zero?
        end

        log(:done) { "Received #{total_expected} messages" }
      rescue ThreadError
        raise NoMessageError,
          "Expected to receive #{total_expected} messages " \
          "but received only #{total_received}"
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      def send(step)
        data = step.fetch("data")
        data = JSON.generate(data) if data.is_a?(Hash)

        client.send(data)

        log(nil) { "Sent message: #{data.truncate(50)}" }
      end

      def wait_all(_step)
        log { "Wait all clients" }
        task.global_holder.wait_all
        log { "All clients" }
      end

      def to_proc
        proc { |step| handle_step(step) }
      end

      private

      attr_reader :client, :task, :logger, :id, :color

      def build_client(...)
        Client.new(...)
      end

      def prepare_receive_error(expected, received)
        <<~MSG
          Action failed: #receive
             -- expected: #{expected.inspect}
             ++ got: #{received} (#{received.class})
        MSG
      end

      def log(state = :begin)
        return unless logger

        if state == :begin
          @last_event_at = Time.now.to_f
        end

        done_info =
          if state == :done
            " (#{(Time.now.to_f - @last_event_at).duration})"
          else
            ""
          end

        msg = "[#{Time.now.strftime("%H:%I:%S.%L")}] client=#{id} #{yield}#{done_info}"

        msg = msg.colorize(color) if color

        logger.puts msg
      end

      def with_logger
        return yield if logger

        @logger = $stdout
        yield
      ensure
        @logger = nil
      end
    end
  end
end
