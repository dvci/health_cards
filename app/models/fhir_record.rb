class FHIRRecord < ApplicationRecord
  self.abstract_class = true

  validate :valid_fhir_json

  def valid_fhir_json
    errs = json.validate
    # byebug if self.class == Immunization

    unless errs.empty?
      err_msg = errs.map { |name, value| "#{name}: #{value}" }.join(', ')
      errors.add(:base, err_msg)
    end
  end
end