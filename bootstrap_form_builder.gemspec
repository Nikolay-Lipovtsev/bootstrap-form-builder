$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bootstrap_form_builder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bootstrap_form_builder"
  s.version     = BootstrapFormBuilder::VERSION
  s.authors     = "Nikolay-Lipovtsev"
  s.email       = "n.lipovtsev@gmail.com"
  s.homepage    = "Test"
  s.summary     = "Test"
  s.description = "Test"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"

  s.add_development_dependency "sqlite3"
end
