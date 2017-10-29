require "websocket-eventmachine-server"

module EchoServer
  class << self
    PORT = 8888
    HOST = "0.0.0.0"

    def start
      EM.run {
        WebSocket::EventMachine::Server.start(host: HOST, port: PORT) do |ws|
          @channel = EM::Channel.new
          ws.onopen do
            sid = @channel.subscribe do |mes|
              ws.send mes # echo to client
            end
            ws.onmessage do |msg|
              @channel.push msg
              ws.send '111' # echo to client
            end
            ws.onclose do
              @channel.unsubscribe sid
            end
          end
        end
      }
    end

    def stop
      # TODO
    end

    def url
      "ws://#{HOST}:#{PORT}"
    end

    def port
      PORT
    end
  end
end
