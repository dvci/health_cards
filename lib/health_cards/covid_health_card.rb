# frozen_string_literal: true

require 'health_cards/attribute_filters'
require 'health_cards/card_types'

module HealthCards
  # Implements HealthCard for use with COVID Vaccination IG
  class COVIDHealthCard < HealthCards::HealthCard
    additional_types 'https://smarthealth.cards#covid19'

    allow type: FHIR::Patient, attributes: %w[name birthDate]
  end
end
