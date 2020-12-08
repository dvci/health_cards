require_relative 'lib/health_cards/version'

Gem::Specification.new do |spec|
  spec.name          = "health_cards"
  spec.version       = HealthCards::VERSION
  spec.authors       = ["Reece Adamson"]
  spec.email         = ["radamson@mitre.org"]

  spec.summary       = %q{Create Health Cards using FHIR and Verifiable Credentials}
  spec.description   = %q{Create Health Cards using FHIR and Verifiable Credentials}
  spec.homepage      = "https://github.com/dvci/health-cards"
  spec.license       = "Apache 2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dvci/health_cards"
  spec.metadata["changelog_uri"] = "https://github.com/dvci/health_cards/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
