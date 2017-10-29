require "yaml"

module WDDirector
  # Read and parse YAML scenario
  class ScenarioReader
    attr_accessor :scenario

    def initialize(file_path)
      @scenario = YAML.load_file(file_path)
    end

    def to_hash
      if scenario.first.key?("client")
        handle_several_scenarios
      else
        handle_simple_scenario
      end
    end

    private

    def handle_actions(scenario)
      hash = scenario.map do |h|
        if h.is_a?(Hash)
          h.map { |k, v| { "type" => k }.merge(handle_multiplier(v)) }
        else
          { "type" => h }
        end
      end
      hash.flatten
    end

    def handle_simple_scenario
      [{ "client" => { "multiplier" => 1,
                       "actions" => handle_actions(scenario) } }]
    end

    def handle_several_scenarios
      scenario.map do |hash|
        { "client" => handle_multiplier("multiplier" => hash["client"]["multiplier"] || "1",
                                        "actions" => handle_actions(hash["client"]["actions"])) }
      end
    end

    def handle_multiplier(hash)
      return hash unless hash.key?("multiplier")

      scale_string = hash["multiplier"]
      scale_string = scale_string.gsub!(":scale", scale.to_s) || "1"
      raise "Multiplier wrong" if (scale_string =~ /^[-+*\\\d ]+$/).nil?

      hash["multiplier"] = eval(scale_string) # rubocop:disable Security/Eval
      hash
    end
  end
end
