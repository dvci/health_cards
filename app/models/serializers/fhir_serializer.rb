# frozen_string_literal: true

# Manages serializing from fhir_models object into FHIR JSON to be stored in the database
module FHIRSerializer
  def load(json)
    json ? FHIR.from_contents(json) : new
  end

  def dump(model)
    unless model.class.module_parent == FHIR
      raise ActiveRecord::SerializationTypeMismatch
    end

    model.to_json
  end
end

FHIR::Patient.class_eval { extend FHIRSerializer }
FHIR::Immunization.class_eval { extend FHIRSerializer }
