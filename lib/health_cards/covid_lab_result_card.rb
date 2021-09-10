# frozen_string_literal: true

module HealthCards
  class COVIDLabResultCard < COVIDHealthCard
    additional_types 'https://smarthealth.cards#laboratory'

    allow type: FHIR::Observation, attributes: %w[status code valueCodeableConcept patient effectiveDateTime]
  end
end
