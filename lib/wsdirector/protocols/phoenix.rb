# frozen_string_literal: true

module WSDirector
  module Protocols
    # Phoenix Channels protocol
    # See https://github.com/phoenixframework/phoenix/blob/master/lib/phoenix/socket/serializers/v2_json_serializer.ex
    class Phoenix < Base
      attr_reader :topics_to_join_ref
      attr_accessor :refs_counter, :join_refs_counter

      def initialize(...)
        super

        @refs_counter = 3
        @join_refs_counter = 3
        @topics_to_join_ref = {}
      end

      def init_client(**options)
        options[:query] ||= {}
        # Make sure we use the v2 of the protocol
        options[:query][:vsn] = "2.0.0"

        super(**options)
      end

      def join(step)
        topic = step.fetch("topic")

        join_ref = join_refs_counter
        self.join_refs_counter += 1

        ref = refs_counter
        self.refs_counter += 1

        log { "Joining #{topic} (##{ref})" }

        cmd = new_command(:phx_join, topic, join_ref:, ref:)

        client.send(cmd.to_json)

        receive({"data>" => new_command(:phx_reply, topic, join_ref:, ref:, payload: {"status" => "ok"})})

        log(:done) { "Joined #{topic} (##{ref})" }
      end

      def leave(step)
        topic = step.fetch("topic")
        join_ref = topics_to_join_ref.fetch(topic)

        ref = refs_counter
        self.refs_counter += 1

        cmd = new_command(:phx_leave, topic, join_ref:, ref:)
        client.send(cmd.to_json)

        receive({"data>" => new_command(:phx_reply, topic, join_ref:, ref:, payload: {"status" => "ok"})})

        log(nil) { "Left #{topic} (##{join_ref})" }
      end

      def send(step)
        return super unless step.key?("topic")

        ref = refs_counter
        self.refs_counter += 1

        topic = step.fetch("topic")
        event = step.fetch("event")
        payload = step["data"]

        super({"data" => new_command(event, topic, payload:, ref:).to_json})
      end

      def receive(step)
        return super unless step.key?("topic")

        topic = step.fetch("topic")
        event = step.fetch("event")

        key = step.key?("data") ? "data" : "data>"
        payload = step.fetch(key)

        cmd = new_command(event, topic, payload:)

        super({key => cmd})
      end

      private

      def new_command(event, topic, join_ref: nil, ref: nil, payload: {})
        [
          join_ref&.to_s,
          ref&.to_s,
          topic.to_s,
          event.to_s,
          payload
        ]
      end
    end
  end
end
