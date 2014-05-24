# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ottick/version'

Gem::Specification.new do |spec|
  spec.name          = "ottick"
  spec.version       = Ottick::VERSION
  spec.authors       = ["Wolfgang Barth"]
  spec.email         = ["wob@swobspace.net"]
  spec.summary       = %q{Connecting OTRS Generic Interface.}
  spec.description   = %q{Connecting OTRS Generic Interface.}
  spec.homepage      = "http://github.com/swobspace/ottick"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
