# frozen_string_literal: true

require_relative "./support/echo_server"

Thread.new { EchoServer.start }

at_exit do
  EchoServer.stop
end
