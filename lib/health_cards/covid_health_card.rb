# frozen_string_literal: true

module HealthCards
  # Implements HealthCard for use with COVID Vaccination IG
  class COVIDHealthCard < HealthCards::HealthCard
    fhir_version '4.0.1'
    additional_types 'https://smarthealth.cards#covid19'
    additional_types 'https://smarthealth.cards#immunization'

    allow FHIR::Patient, %w[name birthDate]
    allow FHIR::Immunization, %w[status vaccineCode patient occurrenceDateTime]
  end
end
