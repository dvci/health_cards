# frozen_string_literal: true

require_relative 'lib/health_cards/version'
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
  spec.email         = ['vci-developers@mitre.org']
  spec.summary       = <<~TEXT
    Create verifiable clinical data using SMART Health Cards.
  TEXT
  spec.description = <<~TEXT
    Health Cards implements SMART Health Cards, a secure and decentralized framework that allows 
    people to prove their vaccination status or medical test results. It is based off of W3C 
    Verifiable Credentials and FHIR R4 health data exchange standards. It allows conversion of 
    clinical data into JWS which may then be embedded into QR codes, exported to smart-health-card 
    files, or returned by a $health-card-issue FHIR operation.
  TEXT
  spec.homepage      = 'https://github.com/dvci/health_cards'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'fhir_models', '>= 4.0.0'
  spec.add_runtime_dependency 'rqrcode'
  spec.add_runtime_dependency 'rqrcode_core', '>= 1.2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dvci/health_cards'
  spec.metadata['changelog_uri'] = 'https://github.com/dvci/health_cards/blob/main/CHANGELOG.md'
  spec.files = ['lib/health_cards.rb', 'LICENSE.txt'] + Dir['lib/health_cards/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
