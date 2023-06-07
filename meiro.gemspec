# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meiro/version'

Gem::Specification.new do |spec|
  spec.name          = "meiro"
  spec.version       = Meiro::VERSION
  spec.authors       = ["Yuki Morohoshi"]
  spec.email         = ["hoshi.sanou@gmail.com"]
  spec.summary       = %q{Random Dungeon Generator}
  spec.description   = %q{Meiro generates maps used for so-called Rogue-like games.}
  spec.homepage      = "http://github.com/hoshi-sano/meiro"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "steep"
end
