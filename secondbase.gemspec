$:.push File.expand_path('../lib', __FILE__)
require 'secondbase/version'

Gem::Specification.new do |s|
  s.name          = 'secondbase'
  s.version       = SecondBase::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Karle Durante', 'Hunter Madison' 'Ken Collins']
  s.email         = ['kdurante@customink.com', 'hunterglenmadison@icloud.com', 'ken@metaskills.net']
  s.homepage      = 'http://github.com/customink/secondbase'
  s.summary       = 'Allow Rails manage second database in your projects'
  s.description   = 'SecondBase provides support to Rails to create a homogeneous environment for a dual database project. Using tasks already familiar to you, this gem enables Rails to work with two primary databases, instead of just one.'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.rdoc_options  = ['--charset=UTF-8']
  s.license       = 'MIT'
  s.add_runtime_dependency     'rails', '~> 4.0'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
end
