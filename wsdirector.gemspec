lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wsdirector/version'

Gem::Specification.new do |spec|
  spec.name          = "wsdirector-cli"
  spec.version       = WSDirector::VERSION
  spec.authors       = ["Kirill Arkhipov", "Grandman", "palkan"]
  spec.email         = ["kirillvs@mail.ru", "root@grandman73.ru", "dementiev.vm@gmail.com"]

  spec.summary       = "Command line tool for testing websocket servers using scenarios."
  spec.description   = "Command line tool for testing websocket servers using scenarios."
  spec.homepage      = "https://github.com/palkan/wsdirector"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.4.0'

  spec.files         = `git ls-files`.split($/).select { |p| p.match(%r{^lib/}) } +
    %w(README.md CHANGELOG.md LICENSE.txt)

  spec.bindir        = "bin"
  spec.executables   = "wsdirector"
  spec.require_paths = ["lib"]

  spec.add_dependency "websocket-client-simple", "~> 0.3"
  spec.add_dependency "concurrent-ruby", "~> 1.0.5"

  spec.add_development_dependency "colorize"
  spec.add_development_dependency "websocket-eventmachine-server", "~> 1.0.1"
  spec.add_development_dependency "rack", "~> 2.0"
  spec.add_development_dependency "litecable", "~> 0.5"
  spec.add_development_dependency "puma", "~> 3.6"

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "rubocop", "~> 0.50"
end
