module WSDirector
  # WSDirector configuration
  class Configuration
    class << self
      attr_accessor :ws_url, :scenario_path, :colorize, :scale

      def colorize?
        colorize == true
      end
    end
  end
end
