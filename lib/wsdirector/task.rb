module WSdirector
  class Task

    def initialize(params = nil, ws_addr)
      run(params, ws_addr)
    end

    def self.start(test_script = nil, ws_addr)
      if test_script
        parsed_params = Configuration.load(test_script)        
        new(parsed_params, ws_addr)
      else
        new(ws_addr)
      end
    end

    private

    def run(params, ws_addr)
    end
  end
end
