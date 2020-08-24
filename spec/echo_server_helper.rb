# frozen_string_literal: true

echo_thread = Thread.new { EchoServer.start }

echo_thread.abort_on_exception = true

# Wait for server to start
sleep 2

RSpec.configure do |config|
  config.after(:suite) { EchoServer.stop }
end
