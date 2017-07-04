require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start

require "wsdirector"
require 'support/echo_server'
require 'support/fixture_helper'
require 'pry'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
