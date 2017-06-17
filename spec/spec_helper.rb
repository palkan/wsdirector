require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'byebug'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "wsdirector"
WSdirector::Configuration.env = :test
::Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }
::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require_relative f }
