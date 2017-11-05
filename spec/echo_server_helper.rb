echo_thread = Thread.new { EchoServer.start }

echo_thread.abort_on_exception = true

# Wait for server to start
sleep 2
