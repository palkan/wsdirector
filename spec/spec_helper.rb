# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "wsdirector"

begin
  require "debug" unless ENV["CI"]
rescue LoadError
end

ENV["RUBY_NEXT_WARN"] = "false"
ENV["RUBY_NEXT_EDGE"] = "1"
ENV["RUBY_NEXT_PROPOSED"] = "1"
require "ruby-next/language/runtime" unless ENV["CI"]

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "tmp/.rspec-status"

  config.define_derived_metadata(file_path: %r{/spec/cases/}) do |metadata|
    metadata[:type] = :integration
  end

  config.include FixtureHelper
  config.include IntegrationHelpers, type: :integration
end
