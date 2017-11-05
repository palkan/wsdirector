# frozen_string_literal: true

module WSDirector
  module Protocols
    # Base protocol describes basic actions
    class Base
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
        receive_matches?(expected, received)
      rescue ThreadError
        raise Error, "Expected to receive #{expected} but nothing has been received"
      end

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

        raise Error, prepare_receive_error(expected, received) if received != expected
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
