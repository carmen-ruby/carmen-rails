$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
#require "carmen-rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "carmen-rails"
  s.version     = '0' #CarmenRails::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CarmenRails."
  s.description = "TODO: Description of CarmenRails."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "carmen" #version

  s.add_development_dependency "minitest"
end
