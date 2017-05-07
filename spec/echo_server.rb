require 'eventmachine'
require 'websocket-eventmachine-server'


module WSdirector
  module EchoServer
    PORT = 9876

    def self.start
      EM::run do
        @channel = EM::Channel.new

        puts "start websocket server - port:#{PORT}"

        WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => PORT) do |ws|
          ws.onopen do
            sid = @channel.subscribe do |mes|
              ws.send mes
            end
            @channel.push "Welcome"

            ws.onmessage do |msg|
              @channel.push "<#{sid}> #{msg}"
            end

            ws.onclose do
              @channel.unsubscribe sid
              @channel.push "<#{sid}> disconnected"
            end
          end
        end
      end
    end
  end
end
