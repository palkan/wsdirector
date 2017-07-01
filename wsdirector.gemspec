<<<<<<< HEAD
=======
# coding: utf-8
>>>>>>> eaef55b... tmp version, tested with action cable
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wsdirector/version'

Gem::Specification.new do |spec|
  spec.name          = "wsdirector"
<<<<<<< HEAD
  spec.version       = WSdirector::VERSION
  spec.authors       = ["Kirill Arkhipov", "palkan"]
  spec.email         = ["kirillvs@mail.ru", "dementiev.vm@gmail.com"]

  spec.summary       = "Command line tool for testing websocket servers using scenarios."
  spec.description   = "Command line tool for testing websocket servers using scenarios."
  spec.homepage      = "https://github.com/palkan/wsdirector"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).select { |p| p.match(%r{^lib/}) } +
    %w(README.md CHANGELOG.md LICENSE.txt)

  spec.bindir        = "bin"
  spec.executables   = "wsdirector"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "aruba"
=======
  spec.version       = WsDirector::VERSION
  spec.authors       = ["Grandman"]
  spec.email         = ["root@grandman73.ru"]

  spec.summary       = %q{WsDirector}
  spec.description   = %q{Tool for testing websockets}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = ['wsdirector']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "websocket-eventmachine-server"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
  spec.add_runtime_dependency "websocket-client-simple", "~> 0.3"
>>>>>>> eaef55b... tmp version, tested with action cable
end
