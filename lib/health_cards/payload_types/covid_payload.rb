# frozen_string_literal: true

require 'health_cards/attribute_filters'
require 'health_cards/payload_types'

module HealthCards
  # Implements Payload for use with COVID Vaccination IG
  class COVIDPayload < HealthCards::Payload
    additional_types 'https://smarthealth.cards#covid19'

    allow type: FHIR::Patient, attributes: %w[identifier name birthDate]
  end
end
