# frozen_string_literal: true

require "concurrent"
require "yaml"
require "json"

require "wsdirector/version"
require "wsdirector/configuration"

# Command line tool for testing websocket servers using scenarios.
module WSDirector
  class Error < StandardError
  end

  class << self
    def config
      @config ||= Configuration.new
    end
  end
end

require "wsdirector/cli"
