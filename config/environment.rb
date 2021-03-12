# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

FHIR.logger.level = 1
Rails.configuration.well_known = YAML.load(File.open('config/well-known.yml'))[Rails.env]