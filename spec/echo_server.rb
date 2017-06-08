require 'eventmachine'
require 'websocket-eventmachine-server'


module WSdirector
  module EchoServer
    PORT = 9876

    def self.start
      func = proc { |param| p param }

      EM::run do
        @channel = EM::Channel.new

        puts "start websocket server - port:#{PORT}"

        WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => PORT) do |ws|
          ws.onopen do
            sid = @channel.subscribe do |mes|
              ws.send mes
            end
            # func.call('connected')
            @channel.push "Welcome"

            ws.onmessage do |msg|
              # func.call(msg)
              # puts msg
              @channel.push "#{msg}"
            end

            ws.onclose do
              # func.call('disconnected')
              @channel.unsubscribe sid
              @channel.push "disconnected"
            end
          end
        end
      end
    end
  end
end
