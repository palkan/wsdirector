# frozen_string_literal: true

module WSDirector
  module Protocols
    # ActionCable protocol
    class ActionCable < Base
      PING_IGNORE = /['"]type['"]:\s*['"]ping['"]/

      # Add ping ignore and make sure that we receive Welcome message
      def init_client(**options)
        options[:ignore] ||= [PING_IGNORE]
        options[:subprotocol] ||= "actioncable-v1-json"

        super(**options)

        receive("data>" => {"type" => "welcome"})
        log(:done) { "Welcomed" }
      end

      def subscribe(step)
        identifier = extract_identifier(step)

        log { "Subsribing to #{identifier}" }

        client.send({command: "subscribe", identifier:}.to_json)

        begin
          receive(
            "data" => {"type" => "confirm_subscription", "identifier" => identifier}
          )
          log(:done) { "Subsribed to #{identifier}" }
        rescue UnmatchedExpectationError => e
          raise unless /reject_subscription/.match?(e.message)
          raise UnmatchedExpectationError, "Subscription rejected to #{identifier}"
        end
      end

      def unsubscribe(step)
        identifier = extract_identifier(step)

        client.send({command: "unsubscribe", identifier:}.to_json)

        log(nil) { "Unsubscribed from #{identifier}" }
      end

      def perform(step)
        identifier = extract_identifier(step)
        action = step.delete("action")

        raise Error, "Action is missing" unless action

        data = step.fetch("data", {}).merge(action:).to_json

        client.send({command: "message", data:, identifier:}.to_json)

        log(nil) { "Performed #{action} on #{identifier}" }
      end

      def receive(step)
        return super unless step.key?("channel")

        identifier = extract_identifier(step)

        key = step.key?("data") ? "data" : "data>"

        message = step.fetch(key, {})

        # Move all protocol-level fields to data
        step[key] = {"identifier" => identifier, "message" => message}.merge(step.slice("offset", "stream_id", "epoch"))

        super
      end

      def receive_all(step)
        messages = step["messages"]

        return super if messages.nil? || messages.empty?

        messages.each do |msg|
          next unless msg.key?("channel")
          identifier = extract_identifier(msg)

          key = msg.key?("data") ? "data" : "data>"

          msg[key] = {"identifier" => identifier, "message" => msg[key]}.merge(step.slice("offset", "stream_id", "epoch"))
        end

        super
      end

      private

      def extract_identifier(step)
        channel = step.delete("channel")
        (step.delete("params") || {}).merge(channel: channel).to_json
      end
    end
  end
end
