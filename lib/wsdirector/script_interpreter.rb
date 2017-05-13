require 'json'
require 'websocket-client-simple'

module WSdirector
  class ScriptInterpreter
    attr_accessor :websocket, :script # , :send_commands, :incoming_messages, :sended_messages # , :receive_commands
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
      # @incoming_messages = []
      # @sended_messages = []
    end

    def run
      init_connection
      recursive_parse(script)
      start_sending_loop
    end

    private

    def init_connection
      @websocket = WebSocket::Client::Simple.connect @ws_addr, headers: { origin: origin(@ws_addr) } do |ws|
        ws.on :message do |event|
          if event.data
            message = JSON.parse(event.data)
          else
            message = event
          end
          incoming_messages << message if start_receive?
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
