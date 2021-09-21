# frozen_string_literal: true

module HealthCards
  class COVIDImmunizationCard < COVIDHealthCard
    additional_types 'https://smarthealth.cards#immunization'

    allow type: FHIR::Immunization, attributes: %w[meta status vaccineCode patient occurrenceDateTime manufacturer lotNumber performer isSubpotent]
  end
end
