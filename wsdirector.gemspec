lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wsdirector/version'

Gem::Specification.new do |spec|
  spec.name          = "wsdirector"
  spec.version       = Wsdirector::VERSION
  spec.authors       = ["Kirillvs"]
  spec.email         = ["kirillvs@mail.ru"]

  spec.summary       = "Command line tool for testing websocket servers using scenarios."
  spec.description   = "Command line tool for testing websocket servers using scenarios."
  spec.homepage      = "https://github.com/palkan/wsdirector"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).select { |p| p.match(%r{^lib/}) } +
    %w(README.md CHANGELOG.md LICENSE.txt)

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "rubocop", "~> 0.50"
end
