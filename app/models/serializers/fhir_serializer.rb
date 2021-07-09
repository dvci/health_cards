# frozen_string_literal: true

# Manages serializing from fhir_models object into FHIR JSON to be stored in the database
module Serializers
  module FHIRSerializer
    def load(json)
      json ? FHIR.from_contents(json) : new
    end

    def dump(model)
      begin
        raise ActiveRecord::SerializationTypeMismatch unless model.class.module_parent == FHIR
      rescue ActiveRecord::SerializationTypeMismatch
        puts model, model.class, model.class.module_parent
        raise StandardError, "Debugging Serialization Failed"
      else
        model.to_json
      end
    end
  end
end

FHIR::Patient.class_eval { extend Serializers::FHIRSerializer }
FHIR::Immunization.class_eval { extend Serializers::FHIRSerializer }
