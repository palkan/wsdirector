# frozen_string_literal: true

require "concurrent"
require "yaml"
require "json"

require "ruby-next"

require "ruby-next/language/setup"
RubyNext::Language.setup_gem_load_path(transpile: true)

require "wsdirector/version"
require "wsdirector/utils"

# Command line tool for testing websocket servers using scenarios.
module WSDirector
  class Error < StandardError
  end
end

require "wsdirector/runner"
