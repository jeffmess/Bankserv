# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bankserv/version"

Gem::Specification.new do |s|
  s.name        = "bankserv"
  s.version     = Bankserv::VERSION
  s.authors     = ["Jeffrey van Aswegen", "Douglas Anderson"]
  s.email       = ["jeffmess@gmail.com", "i.am.douglas.anderson@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{ A rails 3 engine wrapped around the Absa Host 2 Host gem.}
  s.description = %q{This engine allows users to inject requests into a queue to be processed. 
    
                    The queue handles bank account validations, credit payments, debit orders
                    and collecting bank statements/notify me statements. }

  s.rubyforge_project = "bankserv"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "activerecord", "~> 3.0"
  s.add_dependency "i18n"
  s.add_dependency "absa-h2h", "~> 0.1.2"
  s.add_dependency "absa-esd", "~> 0.0.3"
  s.add_dependency "absa-notify-me", "~> 0.0.4"

  s.add_development_dependency 'combustion', '~> 0.3.1'
end
