# frozen_string_literal: true

module WSDirector
  # Read and parse YAML scenario
  class ScenarioReader
    MULTIPLIER_FORMAT = /^[-+*\\\d ]+$/

    class << self
      def parse(file_path)
        contents = YAML.load_file(file_path)

        if contents.first.key?("client")
          parse_multiple_scenarios(contents)
        else
          { "total" => 1, "clients" => [parse_simple_scenario(contents)] }
        end
      end

      private

      def handle_steps(steps)
        steps.flat_map do |step|
          if step.is_a?(Hash)
            type, data = step.to_a.first
            multiplier = parse_multiplier(data.delete("multiplier") || "1")
            Array.new(multiplier) { { "type" => type }.merge(data) }
          else
            { "type" => step }
          end
        end
      end

      def parse_simple_scenario(steps, multiplier = 1)
        {
          "multiplier" => multiplier,
          "steps" => handle_steps(steps)
        }
      end

      def parse_multiple_scenarios(definitions)
        total_count = 0
        clients = definitions.map do |client|
          _, client = client.to_a.first
          multiplier = parse_multiplier(client.delete("multiplier") || "1")
          total_count += multiplier
          parse_simple_scenario(client.fetch("actions", []), multiplier)
        end
        { "total" => total_count, "clients" => clients }
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
