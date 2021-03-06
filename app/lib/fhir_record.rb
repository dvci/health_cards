# frozen_string_literal: true

# Provides validation and utility methods for AR models that store data as FHIR JSON
class FHIRRecord < ApplicationRecord
  self.abstract_class = true

  validate :valid_fhir_json

  after_create :set_fhir_id

  def to_json(*_args)
    json.to_hash
  end

  protected

  def to_fhir_time(time)
    return if time.blank?

    time.strftime('%Y-%m-%d')
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

  def set_fhir_id
    json.id = id
    save!
  end
end
