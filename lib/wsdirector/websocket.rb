require 'websocket-client-simple'

module WSdirector
  class Websocket
    def initialize(ws_addr)
      @ws = WebSocket::Client::Simple.connect ws_addr
    end
  end
end
