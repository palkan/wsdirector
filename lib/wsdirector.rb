# frozen_string_literal: true

require "concurrent"
require "yaml"
require "json"

require "wsdirector/version"
require "wsdirector/utils"

# Command line tool for testing websocket servers using scenarios.
module WSDirector
  class Error < StandardError
  end
end

require "wsdirector/scenario_reader"
require "wsdirector/runner"
