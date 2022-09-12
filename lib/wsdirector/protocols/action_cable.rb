# frozen_string_literal: true

module WSDirector
  module Protocols
    # ActionCable protocol
    class ActionCable < Base
      WELCOME_MSG = {type: "welcome"}.to_json
      PING_IGNORE = /['"]type['"]:\s*['"]ping['"]/

      # Add ping ignore and make sure that we receive Welcome message
      def init_client(**options)
        options[:ignore] ||= [PING_IGNORE]
        options[:subprotocol] ||= "actioncable-v1-json"

        super(**options)

        receive("data" => WELCOME_MSG)
        log(:done) { "Welcomed" }
      end

      def subscribe(step)
        identifier = extract_identifier(step)

        log { "Subsribing to #{identifier}" }

        client.send({command: "subscribe", identifier: identifier}.to_json)

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

        client.send({command: "unsubscribe", identifier: identifier}.to_json)

        log(nil) { "Unsubscribed from #{identifier}" }
      end

      def perform(step)
        identifier = extract_identifier(step)
        action = step.delete("action")

        raise Error, "Action is missing" unless action

        data = step.fetch("data", {}).merge(action: action).to_json

        client.send({command: "message", data: data, identifier: identifier}.to_json)

        log(nil) { "Performed #{action} on #{identifier}" }
      end

      def receive(step)
        return super unless step.key?("channel")

        identifier = extract_identifier(step)
        message = step.fetch("data", {})
        super("data" => {"identifier" => identifier, "message" => message})
      end

      def receive_all(step)
        messages = step["messages"]

        return super if messages.nil? || messages.empty?

        messages.each do |msg|
          next unless msg.key?("channel")
          identifier = extract_identifier(msg)
          msg["data"] = {"identifier" => identifier, "message" => msg["data"]}
        end

        super
      end

      private

      def extract_identifier(step)
        channel = step.delete("channel")
        step.fetch("params", {}).merge(channel: channel).to_json
      end
    end
  end
end
