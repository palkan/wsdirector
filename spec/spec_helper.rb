require 'simplecov'
SimpleCov.start
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "wsdirector"
require 'support/echo_server'
require 'support/fixture_helper'
require 'pry'

