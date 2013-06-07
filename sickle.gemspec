# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sickle/version'

Gem::Specification.new do |spec|
  spec.name          = "sickle"
  spec.version       = Sickle::VERSION
  spec.authors       = ["Tymon Tobolski"]
  spec.email         = ["i@teamon.eu"]
  spec.description   = %q{Sickle is dead simple library for building complex command line tools.}
  spec.summary       = %q{Sickle is dead simple library for building complex command line tools.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
