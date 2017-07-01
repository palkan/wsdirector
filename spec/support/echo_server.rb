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
            sid = @channel.subscribe { |msg| ws.send msg }
            ws.send({ 'type' => 'welcome' }.to_json)
            ws.onmessage do |msg|
              p msg
              subscribe_message = { command: 'subscribe', identifier: "{\"channel\":\"TestChannel\"}" }.to_json
              send_message = { command: 'message', identifier: "{\"channel\":\"TestChannel\"}", data: "{\"text\": \"echo\",\"action\":\"echo\"}" }.to_json
              broadcast_message = { command: 'message', identifier: "{\"channel\":\"TestChannel\"}", data: "{\"text\": \"echo\",\"action\":\"broadcast\"}" }.to_json
              if msg == subscribe_message
                ws.send({identifier: "{\"channel\":\"TestChannel\"}", type: "confirm_subscription"}.to_json)
              end
              if msg == send_message
                ws.send({identifier:"{\"channel\":\"TestChannel\"}", message: { text: 'echo', action: 'echo' } }.to_json)
              end
              if msg == broadcast_message
                @channel.push({identifier:"{\"channel\":\"TestChannel\"}", message: { text: 'echo', action: 'broadcast' }}.to_json)
              end
            end
            ws.onclose do
              @channel.unsubscribe(sid)
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
