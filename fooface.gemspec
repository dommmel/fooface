# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fooface/version"

Gem::Specification.new do |s|
  s.name        = "fooface"
  s.version     = Fooface::VERSION
  s.authors     = ["Dominik"]
  s.email       = ["dommmelcheck@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Tiny tiny facebook library}
  s.description = %q{Subset of mini_fb}

  s.rubyforge_project = "fooface"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency  'oa-oauth', '0.1.6'
  s.add_dependency  'json'
  s.add_dependency  'rest-client'
  
end
