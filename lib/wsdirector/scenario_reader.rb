# frozen_string_literal: true

require "erb"

module WSDirector
  # Read and parse YAML scenario
  class ScenarioReader
    class << self
      include WSDirector::Utils

      def parse(file_path)
        contents = ::YAML.load(ERB.new(File.read(file_path)).result) # rubocop:disable Security/YAMLLoad

        if contents.first.key?("client")
          parse_multiple_scenarios(contents)
        elsif contents.map(&:keys).flatten.include?("loop")
          parse_loop_scenarios(contents)
        else
          {"total" => 1, "clients" => [parse_scenario(contents)]}
        end
      end

      private

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

      def parse_scenario(
        steps,
        multiplier: 1, name: "default", ignore: nil, protocol: "base", loop: false
      )
        {
          "multiplier" => multiplier,
          "steps" => loop ? handle_loop_steps(steps, multiplier) : handle_steps(steps),
          "name" => name,
          "ignore" => ignore,
          "protocol" => protocol
        }
      end

      def parse_multiple_scenarios(definitions)
        total_count = 0
        clients = []

        definitions.each_with_index do |client, i|
          _, client = client.to_a.first
          name = client.delete("name") || (i + 1).to_s
          ignore = parse_ingore(client.fetch("ignore", nil))
          protocol = client.fetch("protocol", "base")

          if client.key?("loop")
            parsed_scenarios = parse_loop_scenarios(
              [client],
              name: name,
              ignore: ignore,
              protocol: protocol
            )
            total_count += parsed_scenarios["total"].to_i

            clients << parsed_scenarios["clients"].first
          else
            multiplier = parse_multiplier(client.delete("multiplier") || "1")
            total_count += multiplier

            clients << parse_scenario(
              client.fetch("actions", []),
              multiplier: multiplier,
              name: name,
              ignore: ignore,
              protocol: protocol
            )
          end
        end

        {"total" => total_count, "clients" => clients}
      end

      def parse_loop_scenarios(scenario_steps, name: "default", ignore: nil, protocol: "base")
        total_count = 0
        parsed_steps = []

        scenario_steps.each do |scenario_step|
          if scenario_step.key?("loop")
            loop_scenario = scenario_step["loop"]
            multiplier = parse_multiplier(loop_scenario["multiplier"] || "1")
            loop_actions = loop_scenario["actions"] || []
            total_count += multiplier

            parsed_steps << parse_scenario(
              loop_actions,
              name: name,
              ignore: ignore,
              multiplier: multiplier,
              protocol: protocol,
              loop: true
            )
          else
            total_count += 1
            parsed_steps << parse_scenario([scenario_step])
          end
        end

        {"total" => total_count, "clients" => parsed_steps}
      end

      def handle_loop_steps(steps, multiplier)
        current_id = 0
        handled_steps = []

        1.upto(multiplier) do |_i|
          steps.each do |current_step|
            if current_step.is_a?(Hash)
              type, data = current_step.to_a.first
              handled_steps << {"type" => type, "id" => current_id}.merge(data)
            else
              handled_steps << {"type" => current_step, "id" => current_id}
            end

            current_id += 1
          end
        end

        handled_steps
      end

      def parse_ingore(str)
        return unless str

        Array(str)
      end
    end
  end
end
