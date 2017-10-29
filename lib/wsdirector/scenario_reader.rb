module WsDirector
  class ScenarioReader
    require 'yaml'

    attr_accessor :scenario

    def initialize(file_path)
      @scenario = YAML.load_file(file_path)
    end

    def to_hash
      hash = scenario.map do |h|
        h.map{ |k, v| { 'type' => k }.merge(v) }
      end
      p hash.flatten
    end
  end
end
