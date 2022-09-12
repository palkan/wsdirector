# frozen_string_literal: true

require "websocket-client-simple"
require "securerandom"

module WSDirector
  # WebSocket client
  class Client
    include CGI::Escape

    WAIT_WHEN_EXPECTING_EVENT = 5

    attr_reader :ws, :id

    # Create new WebSocket client and connect to WSDirector
    # ws URL.
    #
    # Optionally provide an ignore pattern (to ignore incoming message,
    # for example, pings)
    def initialize(url:, ignore: nil, intercept: nil, subprotocol: nil, headers: nil, id: nil, query: nil, cookies: nil)
      @ignore = ignore
      @interceptor = intercept
      has_messages = @has_messages = Concurrent::Semaphore.new(0)
      messages = @messages = Queue.new
      open = Concurrent::Promise.new
      client = self

      options = {}

      if subprotocol
        headers ||= {}
        headers["Sec-WebSocket-Protocol"] = subprotocol
      end

      if cookies
        headers ||= {}
        headers["Cookie"] = cookies.map { "#{_1}=#{escape(_2.to_s)}" }.join("; ")
      end

      if query
        url = "#{url}?#{query.map { "#{_1}=#{escape(_2.to_s)}" }.join("&")}"
      end

      options[:headers] = headers if headers

      @id = id || SecureRandom.hex(6)
      @ws = WebSocket::Client::Simple.connect(url, options) do |ws|
        ws.on(:open) do |_event|
          open.set(true)
        end

        ws.on :message do |msg|
          data = msg.data
          next if data.empty?
          next if client.ignored?(data)
          next if client.intercepted?(data)
          messages << data
          has_messages.release
        end

        ws.on :error do |e|
          messages << Error.new("WebSocket Error #{e.inspect} #{e.backtrace}")
        end
      end

      open.wait!(WAIT_WHEN_EXPECTING_EVENT)
    rescue Errno::ECONNREFUSED
      raise Error, "Failed to connect to #{url}"
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

    def intercepted?(msg)
      return false unless @interceptor

      instance_exec(msg, &@interceptor)
    end
  end
end
