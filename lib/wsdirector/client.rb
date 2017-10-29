module WsDirector
  class Client
    require 'websocket-client-simple'
    require 'json'

    def initialize(path, scenario)
      # queue = [{ type: 'receive', data: { type: 'welcome' }},
      #         { type: 'send', data: { command: 'subscribe', identifier: "{\"channel\":\"TestChannel\"}" }},
      #         { type: 'receive', data: { identifier: "{\"channel\":\"TestChannel\"}", type: "confirm_subscription" } },
      #         { type: 'send', data: { command: "message", identifier: "{\"channel\":\"TestChannel\"}", data: "{\"text\": \"echo\",\"action\":\"echo\"}"} },
      #         { type: 'receive', data: { identifier: "{\"channel\":\"TestChannel\"}", message: { text: "echo", action: "echo"} } }]
      queue = scenario
      ws = WebSocket::Client::Simple.connect path
      ws.on :message do |msg|
        p msg.data
        task = queue.first
        next if task.empty?
        p task['data'].to_json
        if task['data'].to_json == msg.data
          queue.shift
          p 'received'
        end
      end

      ws.on :open do
        puts "-- websocket open (#{ws.url})"
        state = :connected
      end

      ws.on :close do |e|
        puts "-- websocket close (#{e.inspect})"
        exit 1
      end

      ws.on :error do |e|
        puts "-- error (#{e.inspect})"
      end
      while(!ws.open?)
      end
      while(ws.open? && !queue.empty?)
        if queue.first && queue.first['type'] == 'send'
          ws.send(queue.shift['data'].to_json)
          p 'sended'
        end
      end
    end
  end
end
