$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "monsoon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "monsoon-droplet"
  s.version     = Monsoon::VERSION
  s.authors     = "Neil Gupta"
  s.email       = "neil@instructure.com"
  s.homepage    = "https://github.com/neilgupta/monsoon"
  s.summary     = "Super simple message versioning"
  s.description = "Monsoon makes sending messages to an external resource super easy by versioning your messages so other services won't break when your messages change."
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'aws-sdk', '~> 2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
