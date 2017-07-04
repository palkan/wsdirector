require 'em-websocket'
require 'json'

module EchoServer
  extend self

  def start
    EM.run do
      @clients = []
      EM::WebSocket.run(host: '0.0.0.0', port: port) do |ws|
        @channel = EM::Channel.new
        ws.onopen do
          ws.send({ 'type' => 'welcome' }.to_json)
          @clients << ws
        end
        ws.onmessage do |msg|
          subscribe_message_hash = { command: 'subscribe',
                                     identifier: '{"channel":"TestChannel"}' }
          send_message_hash = { command: 'message',
                                identifier: '{"channel":"TestChannel"}',
                                data: '{"text": "echo","action":"echo"}' }
          broadcast_message_hash = { command: 'message',
                                     identifier: '{"channel":"TestChannel"}',
                                     data: '{"text": "echo","action":"broadcast"}' }

          if msg == subscribe_message_hash.to_json
            ws.send({ identifier: '{"channel":"TestChannel"}', type: 'confirm_subscription' }.to_json)
          end
          if msg == send_message_hash.to_json
            ws.send({ identifier: '{"channel":"TestChannel"}', message: { text: 'echo', action: 'echo' } }.to_json)
          end
          if msg == broadcast_message_hash.to_json
            @clients.each do |socket|
              socket.send({ identifier: '{"channel":"TestChannel"}',
                            message: { text: 'echo', action: 'broadcast' } }.to_json)
            end
          end
        end
      end
    end
  end

  def url
    "ws://localhost:#{port}"
  end

  def port
    '8888'
  end
end
