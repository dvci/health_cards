# frozen_string_literal: true

# Manages serializing from fhir_models object into FHIR JSON to be stored in the database
module Serializers
  module FHIRSerializer
    def load(json)
      json ? FHIR.from_contents(json) : new
    end

    def dump(model)
      raise ActiveRecord::SerializationTypeMismatch unless model.class.module_parent == FHIR

      model.to_json
    end
  end
end

FHIR::Patient.class_eval { extend Serializers::FHIRSerializer }
FHIR::Immunization.class_eval { extend Serializers::FHIRSerializer }
FHIR::Observation.class_eval { extend Serializers::FHIRSerializer }
