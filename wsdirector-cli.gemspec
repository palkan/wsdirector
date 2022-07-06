# frozen_string_literal: true

require_relative "lib/wsdirector/version"

Gem::Specification.new do |spec|
  spec.name = "wsdirector-cli"
  spec.version = WSDirector::VERSION
  spec.authors = ["Vladimir Dementyev", "Kirill Arkhipov", "Grandman"]
  spec.email = ["dementiev.vm@gmail.com", "kirillvs@mail.ru", "root@grandman73.ru"]

  spec.summary = "Command line tool for testing WebSocket servers using scenarios."
  spec.description = "Command line tool for testing WebSocket servers using scenarios."
  spec.homepage = "https://github.com/palkan/wsdirector"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 2.6.0"

  spec.files = %w[README.md LICENSE.txt CHANGELOG.md]

  spec.add_dependency "wsdirector", WSDirector::VERSION
  spec.add_dependency "colorize"
end
