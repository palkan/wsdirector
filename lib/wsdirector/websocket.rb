require 'websocket-client-simple'
require 'json'

module WSdirector
  class Websocket

    attr_accessor :addr, :receive_queue, :websocket_client

    # never used, but maybe will be needed in future
    attr_accessor :service_messages

    def initialize(ws_addr)
      @addr = ws_addr
      @receive_queue = []
      @service_messages = []
    end

    def init
      add_received_message = ->(message) { receive_queue << message }
      add_service_message = ->(message) { service_messages << message }
      raise_exception = -> (error) { abort(error) }
      @websocket_client = WebSocket::Client::Simple.connect addr, headers: { origin: Configuration.origin(addr) } do |ws|
        ws.on :message do |event|
          begin
            message = {}
            message['data'] = JSON.parse(event.data)
            message['data']['type'] == 'ping' ? add_service_message.call(message) : add_received_message.call(message)
          rescue
            message = event.data
            add_received_message.call(message)
          end
        end
        ws.on :close do |e|
          raise_exception.call('Websocket client close unexpectedly')
        end
        ws.on :error do |e|
          raise_exception.call("Websocket client get error: #{e}")
        end
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
      JSON.generate(message['data'])
    end
  end
end
