# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lash/version"

Gem::Specification.new do |s|
  s.name        = "lash"
  s.version     = Lash::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Alexander"]
  s.email       = ["paul@appsinyourpants.com"]
  s.homepage    = "http://appsinyourpants.com"
  s.summary     = %q{Static asset bundling for JavaScripts, CSS, CSS sprites and images.}
  s.description = %q{Lash will bundle and compress most common static assets using Googles closure compiler for JavaScript, SASS for CSS and will package loose image files into a single static CSS sprite.}

  s.rubyforge_project = "lash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
