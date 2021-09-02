# frozen_string_literal: true

module HealthCards
  class COVIDImmunizationCard < COVIDHealthCard
    additional_types 'https://smarthealth.cards#immunization'

    allow type: FHIR::Immunization, attributes: %w[status vaccineCode patient occurrenceDateTime]
  end
end
