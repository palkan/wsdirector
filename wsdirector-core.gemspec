# frozen_string_literal: true

require_relative "lib/wsdirector/version"

Gem::Specification.new do |spec|
  spec.name = "wsdirector-core"
  spec.version = WSDirector::VERSION
  spec.authors = ["Vladimir Dementyev", "Kirill Arkhipov", "Grandman"]
  spec.email = ["dementiev.vm@gmail.com", "kirillvs@mail.ru", "root@grandman73.ru"]

  spec.summary = "Scenario-based WebSocket black-box testing"
  spec.description = "Scenario-based WebSocket black-box testing"
  spec.homepage = "https://github.com/palkan/wsdirector"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.bindir = "bin"
  spec.executables = "wsdirector"
  spec.require_paths = ["lib"]

  spec.add_dependency "websocket-client-simple", "~> 0.3"
  spec.add_dependency "concurrent-ruby", "~> 1.0"

  # When gem is installed from source, we add `ruby-next` as a dependency
  # to auto-transpile source files during the first load
  if ENV["RELEASING_ANYWAY"].nil? && File.directory?(File.join(__dir__, ".git"))
    spec.add_runtime_dependency "ruby-next", ">= 0.15.0"
  else
    spec.add_runtime_dependency "ruby-next-core", ">= 0.15.0"
  end

  spec.add_development_dependency "colorize"
  spec.add_development_dependency "websocket-eventmachine-server", "~> 1.0.1"
  spec.add_development_dependency "rack", "~> 2.0"
  spec.add_development_dependency "litecable", "~> 0.5"
  spec.add_development_dependency "puma", "~> 3.6"

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "minitest", "~> 5.9"
end
