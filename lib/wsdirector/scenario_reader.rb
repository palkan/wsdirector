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

      def parse_simple_scenario(
          steps,
          multiplier: 1, name: "default", ignore: nil, protocol: "base"
      )
        {
          "multiplier" => multiplier,
          "steps" => handle_steps(steps),
          "name" => name,
          "ignore" => ignore,
          "protocol" => protocol
        }
      end

      def parse_multiple_scenarios(definitions)
        total_count = 0
        clients = definitions.map.with_index do |client, i|
          _, client = client.to_a.first
          multiplier = parse_multiplier(client.delete("multiplier") || "1")
          name = client.delete("name") || (i + 1).to_s
          total_count += multiplier
          ignore = parse_ingore(client.fetch("ignore", nil))
          parse_simple_scenario(
            client.fetch("actions", []),
            multiplier: multiplier,
            name: name,
            ignore: ignore,
            protocol: client.fetch("protocol", "base")
          )
        end
        { "total" => total_count, "clients" => clients }
      end

      def parse_multiplier(str)
        prepared = str.gsub(":scale", WSDirector.config.scale.to_s)
        raise WSDirector::Error, "Unknown multiplier format: #{str}" unless
          prepared =~ MULTIPLIER_FORMAT

        eval(prepared) # rubocop:disable Security/Eval
      end

      def parse_ingore(str)
        return unless str

        Array(str)
      end
    end
  end
end
