require "yaml"

module WSdirector
  class Configuration
    # timeout secs
    TIMEOUT = 5

    def self.origin(ws_addr)
      full_addr = /(wss?):\/\/(.*)/.match(ws_addr)
      prot = full_addr[1]
      addr = full_addr[2]
      prot = prot == "ws" ? "http" : "https"
      "#{prot}://#{addr}"
    end

    def self.test?
      @env == :test
    end

    class << self
      attr_accessor :env
    end
  end
end
