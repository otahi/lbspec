# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lbspec/version'

Gem::Specification.new do |spec|
  spec.name          = "lbspec"
  spec.version       = Lbspec::VERSION
  spec.authors       = ["OTA Hiroshi"]
  spec.email         = ["ota_h@nifty.com"]
  spec.summary       = "Easily test your Loadbalancers with RSpec."
  spec.description   = "Lbspec is an RSpec plugin for easy Loadbalancer testing."
  spec.homepage      = "https://github.com/otahi/lbspec"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "debugger"

  spec.add_runtime_dependency "rspec"
  spec.add_runtime_dependency "net-ssh"
end
