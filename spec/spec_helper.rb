# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "wsdirector"

begin
  require "pry-byebug"
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "tmp/.rspec-status"

  config.define_derived_metadata(file_path: %r{/spec/integrations/}) do |metadata|
    metadata[:type] = :integration
  end

  config.include FixtureHelper
  config.include IntegrationHelpers, type: :integration

  config.after(:each) { WSDirector.config.reset! }
end
