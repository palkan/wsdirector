# frozen_string_literal: true

require "websocket-client-simple"
require "securerandom"

module WSDirector
  # WebSocket client
  class Client
    WAIT_WHEN_EXPECTING_EVENT = 5

    attr_reader :ws, :id

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

      @id = SecureRandom.hex(6)
      @ws = WebSocket::Client::Simple.connect(path) do |ws|
        ws.on(:open) do |_event|
          open.set(true)
        end

        ws.on :message do |msg|
          data = msg.data
          next if data.empty?
          next if client.ignored?(data)
          messages << data
          has_messages.release
        end

        ws.on :error do |e|
          messages << Error.new("WebSocket Error #{e.inspect} #{e.backtrace}")
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
      @ignore.any? { |pattern| msg =~ Regexp.new(pattern) }
    end
  end
end
