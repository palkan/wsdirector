require 'websocket-client-simple'

module WSdirector
  class Task

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
      ws = WebSocket::Client::Simple.connect ws_addr, headers: { origin: origin(ws_addr) }
      ScriptInterpreter.start(ws, script)
    end

    def run_simple(ws_addr)
      WebSocket::Client::Simple.connect ws_addr, headers: { origin: origin(ws_addr) } do |ws|
        ws.on :message do |event|
          puts ">> #{event.data}"
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

    def origin(ws_addr)
      full_addr = /(wss?):\/\/(.*)/.match(ws_addr)
      prot, addr = full_addr[1], full_addr[2]
      prot = prot == 'ws' ? 'http' : 'https'
      "#{prot}://#{addr}"
    end
  end
end
