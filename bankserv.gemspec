# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bankserv/version"

Gem::Specification.new do |s|
  s.name        = "bankserv"
  s.version     = Bankserv::VERSION
  s.authors     = ["Jeffrey van Aswegen"]
  s.email       = ["jeffmess@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "bankserv"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "i18n"
end
