require 'websocket-eventmachine-server'
require 'json'

module EchoServer
  extend self

  def start
    EM.run {
      WebSocket::EventMachine::Server.start(host: '0.0.0.0', port: self.port) do |ws|
        @channel = EM::Channel.new
        ws.onopen do
          ws.onmessage do |msg|
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
          sid = @channel.subscribe { |msg| ws.send msg }
          ws.send({ 'type' => 'welcome' }.to_json)
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
