# frozen_string_literal: true

require "websocket-eventmachine-server"

module EchoServer
  class << self
    PORT = 8888
    HOST = "0.0.0.0"

    def start
      EM.run {
        @server_id = WebSocket::EventMachine::Server.start(host: HOST, port: PORT) do |ws|
          ws.onopen do
            ws.onmessage do |msg|
              if msg == "receive a to b"
                ws.send "a" # rubocop:disable Performance/StringIdentifierArgument
                ws.send "b" # rubocop:disable Performance/StringIdentifierArgument
              else
                ws.send msg
              end
            end
          end
        end
      }
    end

    def stop
      EM.run {
        EventMachine.stop_server @server_id
      }
    end

    def url
      "ws://#{HOST}:#{PORT}"
    end

    def port
      PORT
    end
  end
end
