# frozen_string_literal: true

module WSDirector
  # Collect ws frame and dump them into a YAML file (or JSON)
  class Snapshot
    def initialize
      @steps = []
      @last_timestamp = nil
    end

    def <<(frame)
      record_gap!
      steps << {"send" => {"data" => frame}}
    end

    def to_yml
      ::YAML.dump(steps)
    end

    def to_json
      steps.to_json
    end

    private

    attr_reader :steps, :last_timestamp

    def record_gap!
      prev_timestamp = last_timestamp
      @last_timestamp = Time.now
      return unless prev_timestamp

      delay = last_timestamp - prev_timestamp
      steps << {"sleep" => {"time" => delay}}
    end
  end
end
