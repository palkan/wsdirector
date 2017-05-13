require 'json'
require 'websocket-client-simple'

module WSdirector
  class ScriptInterpreter
    attr_accessor :websocket, :script
    attr_accessor :work_hash, :expected_hash

    def self.start(ws, script)
      si = new(ws, script)
      si.run
    end

    def initialize(ws, script)
      @ws_addr = ws
      @script = script
      @work_hash = {}
      @expected_hash = {}
    end

    def run
      init_connection
      recursive_parse(script)
      start_sending_loop
    end

    private

    def start_sending_loop
      @work_hash.each do |k, v|
        next if k == 'default'
        set_message_endpoint(k)
        send_to_ws(v)
        sleep 1
      end
    end

    def send_to_ws(message)
      json_message = JSON.generate(message)
      @ws.send(json_message)
    end

    def set_message_endpoint(key)
      @ws.on :message do |event|
        if event.data
          message = JSON.parse(event.data)
        else
          message = event
        end
        @work_hash[key] << message
      end
    end

    def init_connection
      @websocket = WebSocket::Client::Simple.connect @ws_addr, headers: { origin: origin(@ws_addr) } do |ws|
        ws.on :message do |event|
          if event.data
            message = JSON.parse(event.data)
          else
            message = event
          end
          @work_hash['default'] << message if @work_hash['default']
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
    end

    def recursive_parse(script_array)
      return if script_array.empty?
      if script_array.first.keys.include?('send')
        @work_hash[script_array.first['send'].to_s] = []
        @expected_hash[script_array.first['send'].to_s] = []
        script_array.shift
      elsif @expected_hash.keys.last.nil?
        @expected_hash['default'] = []
        @work_hash['default'] = []
      end
      @expected_hash[@expected_hash.keys.last]  << script_array.shift['receive'] if script_array.first
      recursive_parse(script_array)
    end
  end
end
