# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi/authorization/version'

Gem::Specification.new do |spec|
  spec.name          = "jsonapi-authorization"
  spec.version       = JSONAPI::Authorization::VERSION
  spec.authors       = ["Vesa Laakso", "Emil Sågfors"]
  spec.email         = ["laakso.vesa@gmail.com", "emil.sagfors@iki.fi"]
  spec.license       = "MIT"

  spec.summary       = "Generic authorization for jsonapi-resources gem"
  spec.description   = "Adds generic authorization to the jsonapi-resources gem using Pundit."
  spec.homepage      = "https://github.com/venuu/jsonapi-authorization"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "jsonapi-resources", "~> 0.9.12"
  spec.add_dependency "jsonapi-resources"
  spec.add_dependency "pundit", ">= 1.0.0", "< 3.0.0"
  spec.add_dependency "rails", "~> 6.0.0"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", ">= 1.11"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rspec-rails", "~> 4.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "rubocop", "~> 1.14.0"
  spec.add_development_dependency "phare", "~> 1.0.1"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-rails'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'faker'
end
