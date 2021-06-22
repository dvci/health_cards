# frozen_string_literal: true

require_relative 'lib/health_cards/version'
require 'rake'
Gem::Specification.new do |spec|
  spec.name          = 'health_cards'
  spec.version       = HealthCards::VERSION
  spec.authors       = ['Reece Adamson',
                        'Samuel Sayer',
                        'Stephen MacVicar',
                        'Neelima Karipineni',
                        'Daniel Lee',
                        "Mick O'Hanlon",
                        'Priyank Madria',
                        'Shaumik Ashraf']
  spec.email         = ['radamson@mitre.org']
  spec.summary       = <<EOT
Create SMART Health Cards using FHIR and Verifiable Credentials for secure and decentralized 
presentation of clinical information.
EOT
  spec.description   = <<EOT
Health Cards implements SMART Health Cards, a secure and decentralized framework that allows 
people to prove their vaccination status or medical test results. It is built on top of FHIR 4 
healthcare interoperability standards and W3C Verifiable Credentials. It allows conversion of
medical data into JWS which may then be embedded into QR codes.
EOT  
  spec.homepage      = 'https://github.com/dvci/health-cards'
  spec.license       = 'Apache 2.0'
  spec.add_runtime_dependency 'fhir_models', '>= 4.0.0'
  spec.add_runtime_dependency 'rqrcode'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dvci/health_cards'
  spec.metadata['changelog_uri'] = 'https://github.com/dvci/health_cards/CHANGELOG.md'
  spec.files = ['lib/health_cards.rb', 'LICENSE.txt'] + Dir['lib/health_cards/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
