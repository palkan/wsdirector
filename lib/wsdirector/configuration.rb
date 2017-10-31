# frozen_string_literal: true

module WSDirector
  # WSDirector configuration
  class Configuration
    attr_accessor :ws_url, :scenario_path, :colorize, :scale

    def initialize
      reset!
    end

    def colorize?
      colorize == true
    end

    # Restore to defaults
    def reset!
      @scale = 1
      @colorize = false
    end
  end
end
