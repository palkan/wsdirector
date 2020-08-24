# frozen_string_literal: true

module CableServer
  class << self
    PORT = 8898
    HOST = "0.0.0.0"

    def start
      _, @out, @err, @server_thr = Open3.popen3(
        "bundle exec puma cable.ru -b tcp://#{HOST}:#{PORT}",
        chdir: __dir__
      )
      ensure_started
    end

    def ensure_started(timeout = 5)
      loop do
        raise "Failed to start!" if timeout.zero?
        out = @out.readline
        break if /Listening on tcp/.match?(out)
        timeout -= 0.5
        sleep 0.5
      end
    end

    def stop
      Process.kill(9, @server_thr.pid)
    end

    def url
      "ws://#{HOST}:#{PORT}/cable"
    end

    def port
      PORT
    end
  end
end
