require 'websocket-client-simple'
require 'json'

module WSdirector
  class Websocket

    attr_accessor :addr, :receive_queue, :websocket_client
    def initialize(ws_addr)
      @addr = ws_addr
      @receive_queue = []
    end

    def init
      add_received_message = ->(message) { receive_queue << message }
      raise_exception = -> (error) { abort(error) }
      @websocket_client = WebSocket::Client::Simple.connect addr, headers: { origin: Configuration.origin(addr) }
      @websocket_client.on :message do |event|
        begin
          message = JSON.parse(event.data)
        rescue
          message = event.data
        end
        add_received_message.call(message)
      end
      @websocket_client.on :close do |e|
        raise_exception.call('Websocket client close unexpectedly')
      end
      @websocket_client.on :error do |e|
        raise_exception.call("Websocket client get error: #{e}")
      end
    end

    def receive(receive_array)
      i = 0
      while receive_array.any?(&:nil?) do
        if receive_queue.first
          receive_array[i] = receive_queue.shift
          i += 1
        end
      end
      receive_array
    end

    def wait_until_hanshaked
      while !websocket_client.instance_eval "@handshaked";end
    end

    def send_receive(send_command, receive_array)
      s = parse_message(send_command)
      wait_until_hanshaked
      status = websocket_client.send(s)
      abort("Client handshaked? #{websocket_client.instance_eval "@handshaked"}") unless status
      i = 0
      while receive_array.any?(&:nil?) do
        if receive_queue.first
          receive_array[i] = receive_queue.shift
          i += 1
        end
      end
      receive_array
    end

    def parse_message(message)
      return message unless message.is_a?(Hash) && message['data']
      JSON.generate(message)
    end
  end
end
