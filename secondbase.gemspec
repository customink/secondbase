Gem::Specification.new do |gem|
  gem.name = 'secondbase'
  gem.version = '0.6.0'

  gem.authors = ['karledurante']
  gem.email = 'kdurante@customink.com'
  gem.summary = 'Allow Rails manage second database in your projects'
  gem.description = 'Secondbase provides support to Rails to create a homogeneous environment for a dual database project.  Using the rake tasks already familiar to you, this gem enables Rails to work with two primary databases, instead of just one.'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test}/*`.split("\n")

  gem.homepage = 'http://github.com/karledurante/secondbase'
  gem.licenses = ['MIT']
  gem.require_paths = ['lib']

  gem.add_dependency('activerecord', '<= 4.0.0')
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
end
