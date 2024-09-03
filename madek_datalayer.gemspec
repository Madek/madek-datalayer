$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'madek_datalayer/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'madek_datalayer'
  s.version     = MadekDatalayer::Version
  s.authors     = ['Thomas Schank']
  s.email       = ['DrTom@schank.ch']
  s.homepage    = 'https://github.com/Madek/madek-datalayer'
  s.summary     = 'MadekDatalayer'
  s.description = 'MadekDatalayer'
  s.license     = 'GPL'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

end
