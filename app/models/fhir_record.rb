# frozen_string_literal: true

# Provides validation and utility methods for AR models that store data as FHIR JSON
class FHIRRecord < ApplicationRecord
  self.abstract_class = true

  validate :valid_fhir_json

  protected

  def to_fhir_time(time)
    return if time.blank?

    case time
    when String
      time
    else
      time.strftime('%Y-%m-%d')
    end
  end

  def from_fhir_time(time_string)
    Date.parse(time_string) if time_string.present?
  end

  def valid_fhir_json
    errs = json.validate
    return if errs.empty?

    err_msg = errs.map { |name, value| "#{name}: #{value}" }.join(', ')
    errors.add(:base, err_msg)
  end
end
