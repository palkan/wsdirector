module WsDirector
  class ScenarioReader
    require 'yaml'

    attr_accessor :scenario

    def initialize(file_path)
      @scenario = YAML.load_file(file_path)
    end

    def to_hash
      hash = scenario.map do |h|
        if h.is_a?(Hash)
          h.map{ |k, v| { 'type' => k }.merge(v) }
        else
          { 'type' => h }
        end
      end
      p hash.flatten
    end
  end
end
