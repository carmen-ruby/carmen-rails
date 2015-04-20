$:.push File.expand_path("../lib", __FILE__)

require "carmen/rails/version"

Gem::Specification.new do |s|
  s.name        = "carmen-rails"
  s.version     = Carmen::Rails::VERSION
  s.authors     = ["Jim Benton"]
  s.email       = ["jim@autonomousmachine.com"]
  s.homepage    = "http://github.com/jim/carmen-rails"
  s.summary     = "Rails adapter for Carmen"
  s.description = "Provides country_select and subregion_select form helpers."

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "< 5.0", ">= 3.0"
  s.add_dependency "carmen", "~> 1.0.0"

  s.add_development_dependency "rails-dom-testing", "~> 1.0"
  s.add_development_dependency "minitest", "< 6.0", ">= 4.2"
  s.add_development_dependency "appraisal", ">= 1.0"
  s.add_development_dependency "pry", "~> 0.9"
  s.add_development_dependency "test-unit", "~> 3.0"
end
