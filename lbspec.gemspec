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
  spec.add_development_dependency "rake", "~> 10.2"
  spec.add_development_dependency 'rubocop', '0.24.1'
  spec.add_development_dependency "coveralls", "~> 0.7"
  spec.add_development_dependency "highline", "~> 1.6"

  spec.add_runtime_dependency "rspec", "~> 3.1"
  spec.add_runtime_dependency "net-ssh", "~> 2.8"
end
