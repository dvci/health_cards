# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register 'application/smart-health-card', :healthcard, [], ['smart-health-card']
Mime::Type.register 'application/fhir+json', :fhir_json
Mime::Type.register "application/pdf", :pdf
