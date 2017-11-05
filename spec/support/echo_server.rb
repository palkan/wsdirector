require "websocket-eventmachine-server"

module EchoServer
  class << self
    PORT = 8888
    HOST = "0.0.0.0".freeze

    def start
      EM.run {
        @server_id = WebSocket::EventMachine::Server.start(host: HOST, port: PORT) do |ws|
          ws.onopen do
            ws.onmessage do |msg|
              ws.send msg
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
