# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ontrac/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brian Abreu"]
  gem.email         = ["brian@nuts.com"]
  gem.description   = %q{Provides an interface to the OnTrac web services API}
  gem.summary       = %q{Interfaces with the OnTrac web services API to look up shipping rates, generate labels, and track shipments}
  gem.homepage      = "https://github.com/brewski/ontrac-web-services"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ontrac-web-services"
  gem.require_paths = ["lib"]
  gem.version       = Ontrac::VERSION

  gem.required_ruby_version = '>= 1.9.0'
  gem.add_dependency("activesupport")
  gem.add_dependency("nokogiri")
end
