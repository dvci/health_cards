# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

FHIR.logger.level = 1

smart_file = File.open('config/well-known.yml').read
smart_config = ERB.new(smart_file).result
Rails.configuration.well_known = YAML.load(smart_config)[Rails.env]