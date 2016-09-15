# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remote_service/version'

Gem::Specification.new do |spec|
  spec.name          = "remote_service"
  spec.version       = RemoteService::VERSION
  spec.authors       = ["Marek Galovic"]
  spec.email         = ["galovic.galovic@gmail.com"]

  spec.summary       = %q{Dead-simple ruby RPC}
  spec.description   = %q{NATS based client/server implementation that allows you to easily call remote services.}
  spec.homepage      = "https://github.com/marekgalovic/ruby-remote-service"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'nats', '~> 0.8.0'
  spec.add_runtime_dependency 'msgpack', '~> 0.7.4'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'mocha', '~> 1.1'
end
