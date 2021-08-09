# frozen_string_literal: true

require 'health_cards/attribute_filters'
require 'health_cards/card_types'

module HealthCards
  # Implements HealthCard for use with COVID Vaccination IG
  class COVIDHealthCard < HealthCards::HealthCard
    fhir_version '4.0.1'

    additional_types 'https://smarthealth.cards#covid19'
    additional_types 'https://smarthealth.cards#immunization'

    # allow type: FHIR::Patient, attributes: %w[name birthDate]
    # allow type: FHIR::Immunization, attributes: %w[status vaccineCode patient occurrenceDateTime]

    # display :patient, name: { |pat| patient }
    # display_collection :immunization, code

    bundle_member :patient, type: FHIR::Patient, allow: %w[name birthDate]
    bundle_collection :immunizations, type: FHIR:Immunizations, allow: %w[status vaccineCode patient occurrenceDateTime]
  end
end
