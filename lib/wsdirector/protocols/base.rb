# frozen_string_literal: true

module WSDirector
  module Protocols
    # Base protocol describes basic actions
    class Base
      include WSDirector::Utils

      def initialize(task)
        @task = task
      end

      def init_client(**options)
        @client = build_client(**options)
      end

      def handle_step(step)
        type = step.delete("type")
        raise Error, "Unknown step: #{type}" unless respond_to?(type)
        public_send(type, step)
      end

      def receive(step)
        expected = step.fetch("data")
        received = client.receive
        raise UnmatchedExpectationError, prepare_receive_error(expected, received) unless
          receive_matches?(expected, received)
      rescue ThreadError
        raise NoMessageError, "Expected to receive #{expected} but nothing has been received"
      end

      # rubocop: disable Metrics/CyclomaticComplexity
      def receive_all(step)
        messages = step.delete("messages")
        raise ArgumentError, "Messages array must be specified" if
          messages.nil? || messages.empty?

        expected =
          Hash[messages.map do |msg|
            multiplier = parse_multiplier(msg.delete("multiplier") || "1")
            [msg["data"], multiplier]
          end]

        total_expected = expected.values.sum
        total_received = 0

        total_expected.times do
          received = client.receive

          total_received += 1

          match = expected.find { |k, _| receive_matches?(k, received) }

          raise UnexpectedMessageError, "Unexpected message received: #{received}" if
            match.nil?

          expected[match.first] -= 1
          expected.delete(match.first) if expected[match.first].zero?
        end
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
      end

      def wait_all(_step)
        task.global_holder.wait_all
      end

      def to_proc
        proc { |step| handle_step(step) }
      end

      private

      attr_reader :client, :task

      def build_client(**options)
        Client.new(**options)
      end

      def receive_matches?(expected, received)
        received = JSON.parse(received) if expected.is_a?(Hash)

        received == expected
      end

      def prepare_receive_error(expected, received)
        <<~MSG
          Action failed: #receive
             -- expected: #{expected}
             ++ got: #{received}
        MSG
      end
    end
  end
end
