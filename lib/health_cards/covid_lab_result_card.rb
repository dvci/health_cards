# frozen_string_literal: true

module HealthCards
  class COVIDLabResultCard < COVIDHealthCard
    additional_types 'https://smarthealth.cards#laboratory'

    allow type: FHIR::Observation,
          attributes: %w[meta status code subject effectiveDateTime effectivePeriod performer
                         valueCodeableConcept valueQuantity valueString referenceRange]
  end
end
