# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "yell-adapters-syslog"
  s.version     = "0.13.4"

  s.authors     = ["Rudolf Schmidt"]

  s.homepage    = "http://rubygems.org/gems/yell"
  s.summary     = %q{Yell - Your Extensible Logging Library }
  s.description = %q{Syslog adapter for Yell}

  s.rubyforge_project = "yell"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.require_paths = ["lib"]

  s.add_runtime_dependency "yell", "~> 1.1"
end
