require 'websocket-client-simple'

module WSdirector
  class Task

    #exclude all logic from here to start. Rewrite tests
    def initialize(params = nil, ws_addr)
      if params
        run_with_script(params, ws_addr)
      else
        run_simple(ws_addr)
      end
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

    def run_with_script(script, ws_addr)
      ScriptInterpreter.start(ws_addr, script)
    end

    def run_simple(ws_addr)
      WebSocket::Client::Simple.connect ws_addr, headers: { origin: Configuration.origin(ws_addr) } do |ws|
        ws.on :message do |event|
          puts "from run_simple >> #{event.data}"
        end

        ws.on :open do
          puts "Connection established - #{ws.url}"
        end

        ws.on :close do |e|
          puts "Connection closed (#{e.inspect})"
          exit 1
        end

        ws.on :error do |e|
          puts "Error (#{e.inspect})"
        end
      end
    rescue => error
      raise "Connection problems - #{error}"
    end
  end
end
