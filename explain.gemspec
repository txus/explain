# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'explain/version'

Gem::Specification.new do |gem|
  gem.name          = "explain"
  gem.version       = Explain::VERSION
  gem.authors       = ["Josep M. Bach"]
  gem.email         = ["josep.m.bach@gmail.com"]
  gem.description   = %q{Explain explains your Ruby code in natural language.}
  gem.summary       = %q{Explain explains your Ruby code in natural language.}
  gem.homepage      = "https://github.com/txus/explain"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
