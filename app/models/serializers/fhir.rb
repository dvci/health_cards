module Serializers
  module FHIR

    def load(json)
      FHIR.from_contents(json)
    end

    def dump(model)
      errs = model.validate
      unless errs.empty?
	err_msg = model.errors.map { |name, value| "#{name}: #{value}" }.join(', ')
	raise ActiveRecord::SerializationTypeMismatch(err_msg)
      end
      model.to_json
    end

  end

end

FHIR::Patient.class_eval { include Serializers::FHIR }