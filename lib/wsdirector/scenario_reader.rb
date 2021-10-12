# frozen_string_literal: true

require "erb"
require "json"
require "wsdirector/ext/deep_dup"

module WSDirector
  # Read and parse different scenarios
  class ScenarioReader
    using WSDirector::Ext::DeepDup

    class << self
      include WSDirector::Utils

      def parse(scenario)
        contents =
          if File.file?(scenario)
            parse_file(scenario)
          else
            [JSON.parse(scenario)]
          end.flatten

        if contents.first.key?("client")
          contents = transform_with_loop(contents, multiple: true)
          parse_multiple_scenarios(contents)
        else
          contents = transform_with_loop(contents)
          {"total" => 1, "clients" => [parse_simple_scenario(contents)]}
        end
      end

      private

      JSON_FILE_FORMAT = /.+.(json)\z/.freeze
      private_constant :JSON_FILE_FORMAT

      def parse_file(file)
        if file.match?(JSON_FILE_FORMAT)
          JSON.parse(File.read(file))
        else
          ::YAML.load(ERB.new(File.read(file)).result) # rubocop:disable Security/YAMLLoad
        end
      end

      def handle_steps(steps)
        steps.flat_map.with_index do |step, id|
          if step.is_a?(Hash)
            type, data = step.to_a.first

            data["sample"] = [1, parse_multiplier(data["sample"])].max if data["sample"]

            multiplier = parse_multiplier(data.delete("multiplier") || "1")
            Array.new(multiplier) { {"type" => type, "id" => id}.merge(data) }
          else
            {"type" => step, "id" => id}
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
        {"total" => total_count, "clients" => clients}
      end

      def transform_with_loop(contents, multiple: false)
        contents.flat_map do |content|
          loop_data = content.dig("client", "loop") || content.dig("loop")
          next content unless loop_data

          loop_multiplier = parse_multiplier(loop_data["multiplier"] || "1")

          if multiple
            content["client"]["actions"] = (loop_data["actions"] * loop_multiplier).map(&:deep_dup)
            content
          else
            loop_data["actions"] * loop_multiplier
          end
        end
      end

      def parse_ingore(str)
        return unless str

        Array(str)
      end
    end
  end
end
