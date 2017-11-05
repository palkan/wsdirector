# frozen_string_literal: true

require "websocket-client-simple"

module WSDirector
  # WebSocket client
  class Client
    WAIT_WHEN_EXPECTING_EVENT = 5

    attr_reader :ws

    # Create new WebSocket client and connect to WSDirector
    # ws URL.
    #
    # Optionally provide an ignore pattern (to ignore incoming message,
    # for example, pings)
    def initialize(ignore: nil)
      @ignore = ignore
      has_messages = @has_messages = Concurrent::Semaphore.new(0)
      messages = @messages = Queue.new
      path = WSDirector.config.ws_url
      open = Concurrent::Promise.new
      client = self

      @ws = WebSocket::Client::Simple.connect(path) do |ws|
        ws.on(:open) do |_event|
          open.set(true)
        end

        ws.on :message do |msg|
          msg = msg.data
          next if client.ignored?(msg)
          messages << msg
          has_messages.release
        end

        ws.on :error do |e|
          raise Error, "WebSocket Error #{e.inspect} #{e.backtrace}"
        end
      end

      open.wait!(WAIT_WHEN_EXPECTING_EVENT)
    rescue Errno::ECONNREFUSED
      raise Error, "Failed to connect to #{path}"
    end

    def receive(timeout = WAIT_WHEN_EXPECTING_EVENT)
      @has_messages.try_acquire(1, timeout)
      msg = @messages.pop(true)
      raise msg if msg.is_a?(Exception)
      msg
    end

    def send(msg)
      @ws.send(msg)
    end

    def ignored?(msg)
      return false unless @ignore
      @ignore.any? { |pattern| msg =~ pattern }
    end
  end
end
