# frozen_string_literal: true

require 'health_cards/attribute_filters'
require 'health_cards/card_types'

module HealthCards
  # Implements HealthCard for use with COVID Vaccination IG
  class COVIDHealthCard < HealthCards::HealthCard
    fhir_version '4.0.1'

    additional_types 'https://smarthealth.cards#covid19'
    additional_types 'https://smarthealth.cards#immunization'
    additional_types 'https://smarthealth.cards#labresult'

    allow FHIR::Patient, %w[name birthDate]
    allow FHIR::Immunization, %w[status vaccineCode patient occurrenceDateTime]
    allow FHIR::Observation, %w[status result code patient effectiveDateTime]
  end
end
