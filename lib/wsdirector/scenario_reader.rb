# frozen_string_literal: true

require "yaml"

module WSDirector
  # Read and parse YAML scenario
  class ScenarioReader
    MULTIPLIER_FORMAT = /^[-+*\\\d ]+$/

    MULTIPLIER_KEY = "multiplier"
    ACTIONS_KEY = "actions"
    STEPS_KEY = "steps"
    CLIENT_KEY = "client"
    STEP_TYPE_KEY = "type"

    class << self
      def parse(file_path)
        contents = YAML.load_file(file_path)

        if contents.first.key?(CLIENT_KEY)
          parse_multiple_scenarios(contents)
        else
          [parse_simple_scenario(contents)]
        end
      end

      private

      def handle_steps(steps)
        steps.flat_map do |step|
          if step.is_a?(Hash)
            type, data = step.to_a.first
            multiplier = parse_multiplier(data.delete(MULTIPLIER_KEY) || "1")
            Array.new(multiplier) { { STEP_TYPE_KEY => type }.merge(data) }
          else
            { STEP_TYPE_KEY => step }
          end
        end
      end

      def parse_simple_scenario(steps, multiplier = 1)
        {
          MULTIPLIER_KEY => multiplier,
          STEPS_KEY => handle_steps(steps)
        }
      end

      def parse_multiple_scenarios(clients)
        clients.map do |client|
          _, client = client.to_a.first
          multiplier = parse_multiplier(client.delete(MULTIPLIER_KEY) || "1")
          parse_simple_scenario(client.fetch(ACTIONS_KEY, []), multiplier)
        end
      end

      def parse_multiplier(str)
        prepared = str.gsub(":scale", WSDirector.config.scale.to_s)
        raise WSDirector::Error, "Unknown multiplier format: #{str}" unless
          prepared =~ MULTIPLIER_FORMAT

        eval(prepared) # rubocop:disable Security/Eval
      end
    end
  end
end
