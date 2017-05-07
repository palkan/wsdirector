module WSdirector
  class ScriptInterpreter
    attr_accessor :ws, :script

    def initialize(ws, script)
      @ws = ws
      @script = script
    end

    def run
    end

    def self.start(ws, script)
      si = new(ws, script)
      si.run
    end
  end
end
