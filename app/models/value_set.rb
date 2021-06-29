class ValueSet < ApplicationRecord

serialize :json, FHIR::CodeableConcept

end
