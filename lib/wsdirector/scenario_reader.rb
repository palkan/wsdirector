# frozen_string_literal: true

require "erb"
require "json"
require "wsdirector/ext/deep_dup"

module WSDirector
  # Read and parse different scenarios
  class ScenarioReader
    using WSDirector::Ext::DeepDup

    include WSDirector::Utils

    class << self
      def parse(scenario, **options)
        new(**options).parse(scenario)
      end
    end

    attr_reader :default_connections_options, :locals

    def initialize(scale: 1, connection_options: {}, locals: {})
      @scale = scale
      @default_connections_options = connection_options
      @locals = locals
    end

    def parse(scenario)
      contents =
        if scenario.is_a?(String)
          if File.file?(scenario)
            parse_file(scenario)
          else
            parse_from_str(scenario).then do
              next _1 if _1.is_a?(Array)
              [_1]
            end
          end.flatten
        else
          scenario
        end

      contents.map! do |item|
        item.is_a?(String) ? {item => {}} : item
      end

      if contents.first&.key?("client")
        contents = transform_with_loop(contents, multiple: true)
        parse_multiple_scenarios(contents)
      else
        contents = transform_with_loop(contents)
        {"total" => 1, "clients" => [parse_simple_scenario(contents)]}
      end
    end

    private

    JSON_FILE_FORMAT = /.+.(json)\z/
    private_constant :JSON_FILE_FORMAT

    def parse_from_str(contents)
      JSON.parse(contents)
    rescue JSON::ParserError
      parse_yaml(contents)
    end

    def parse_file(file)
      if file.match?(JSON_FILE_FORMAT)
        JSON.parse(File.read(file))
      else
        parse_yaml(file)
      end
    end

    def parse_yaml(path)
      contents = File.file?(path) ? File.read(path) : path

      if defined?(ERB)
        contents = ERB.new(contents).result(erb_context)
      end

      ::YAML.load(contents, aliases: true, permitted_classes: [Date, Time, Regexp]) || {}
    rescue ArgumentError
      ::YAML.load(contents) || {}
    end

    def handle_steps(steps)
      steps.flat_map.with_index do |step, id|
        if step.is_a?(Hash)
          type, data = step.to_a.first

          data["sample"] = [1, parse_multiplier(data["sample"])].max if data["sample"]

          multiplier = parse_multiplier(data.delete("multiplier") || "1")

          if type == "loop"
            handle_steps(data.fetch("actions")) * multiplier
          else
            Array.new(multiplier) { {"type" => type, "id" => id}.merge(data) }
          end
        else
          {"type" => step, "id" => id}
        end
      end
    end

    def parse_simple_scenario(
      steps,
      multiplier: 1, name: "default", ignore: nil, protocol: "base",
      connection_options: {}
    )
      {
        "multiplier" => multiplier,
        "steps" => handle_steps(steps),
        "name" => name,
        "ignore" => ignore,
        "protocol" => protocol,
        "connection_options" => default_connections_options.merge(connection_options)
      }
    end

    def parse_multiple_scenarios(definitions)
      total_count = 0
      clients = definitions.map.with_index do |client, i|
        _, client = client.to_a.first
        multiplier = parse_multiplier(client.delete("multiplier") || "1")
        name = client.delete("name") || (i + 1).to_s
        connection_options = client.delete("connection_options") || {}
        total_count += multiplier
        ignore = parse_ignore(client.fetch("ignore", nil))
        protocol = client.fetch("protocol", "base")

        parse_simple_scenario(
          client.fetch("actions", []),
          multiplier:,
          name:,
          ignore:,
          protocol:,
          connection_options:
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

    def parse_ignore(str)
      return unless str

      Array(str)
    end

    def erb_context
      binding.then do |b|
        locals.each do
          b.local_variable_set(_1, _2)
        end

        b
      end
    end
  end
end
