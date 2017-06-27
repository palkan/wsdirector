require 'websocket-eventmachine-server'

module EchoServer
  extend self

  def start
    EM.run {
      WebSocket::EventMachine::Server.start(host: '0.0.0.0', port: self.port) do |ws|
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

  def url
    "ws://localhost:#{self.port}"
  end

  def port
    '8888'
  end
end
