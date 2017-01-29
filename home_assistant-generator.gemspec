# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'home_assistant/generator/version'

Gem::Specification.new do |spec|
  spec.name          = "home_assistant-generator"
  spec.version       = HomeAssistant::Generator::VERSION
  spec.authors       = ["Grégoire Seux"]
  spec.email         = ["grego_homeassistant@familleseux.net"]

  spec.summary       = %q{Helper to generate home-assistant configuration}
  spec.license       = "Apache License v2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
