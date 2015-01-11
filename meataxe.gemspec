# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meataxe/version'

Gem::Specification.new do |spec|
  spec.name          = "meataxe"
  spec.version       = Meataxe::VERSION
  spec.authors       = ["Kam Low"]
  spec.email         = ["hello@sourcey.com"]
  spec.description   = %q{Meataxe is a collection of killer Capistrano deployment scripts.}
  spec.summary       = %q{Killer Capistrano deployment scripts.}
  spec.homepage      = "http://github.com/sourcey/meataxe"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
