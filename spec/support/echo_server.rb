require 'websocket-eventmachine-server'
require 'json'

module EchoServer
  extend self

  def start
    EM.run {
      WebSocket::EventMachine::Server.start(host: '0.0.0.0', port: self.port) do |ws|
        @channel = EM::Channel.new
        ws.onopen do
          ws.send({ 'type' => 'welcome' }.to_json)
        end
        ws.onmessage do |msg|
          p msg
          subscribe_message = { command: 'subscribe', identifier: "{\"channel\":\"TestChannel\"}" }.to_json
          send_message = { command: 'message', identifier: "{\"channel\":\"TestChannel\"}", data: "{\"text\": \"echo\",\"action\":\"echo\"}" }.to_json
          if msg == subscribe_message
            ws.send({identifier: "{\"channel\":\"TestChannel\"}", type: "confirm_subscription"}.to_json)
          end
          if msg == send_message
            ws.send({identifier:"{\"channel\":\"TestChannel\"}", message: { text: 'echo', action: 'echo' } }.to_json)
          end
        end
        ws.onclose do
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
