# frozen_string_literal: true
require_relative 'lib/health_cards/version'
require 'rake'
Gem::Specification.new do |spec|
  spec.name          = 'health_cards'
  spec.version       = HealthCards::VERSION
  spec.authors       = ['Reece Adamson']
  spec.email         = ['radamson@mitre.org']
  spec.summary       = 'Create Health Cards using FHIR and Verifiable Credentials'
  spec.description   = 'Create Health Cards using FHIR and Verifiable Credentials'
  spec.homepage      = 'https://github.com/dvci/health-cards'
  spec.license       = 'Apache 2.0'
  spec.add_runtime_dependency 'fhir_models'
  spec.add_runtime_dependency 'json-minify'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dvci/health_cards'
  spec.metadata['changelog_uri'] = 'https://github.com/dvci/health_cards/CHANGELOG.md'
  spec.files = ['lib/health_cards.rb'] + Dir['/lib/health_cards/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end