# frozen_string_literal: true

# Enables models to act a shim around a FHIR JSON blob
module FHIRJsonStorage
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    def validate_fhir_json
      fhir_instance.validate.each do |name, message|
	errors.add(name, message)
      end
    rescue StandardError
      errors.add(:base, "Can't serialize invalid FHIR JSON")
    end

    def _to_fhir_json
      fhir_resource = FHIR.const_get(fhir_resource_name).new(to_fhir_json)
      self.json = fhir_resource.to_json
    end

    def _from_fhir_json
      assign_attributes(from_fhir_json(fhir_instance))
    end

    def to_fhir_json
      raise 'Models must define this method for themselves'
    end

    def from_fhir_json(_instance)
      raise 'Models must define this method for themselves'
    end

    def fhir_resource_name
      self.class.name
    end

    def fhir_instance
      return @instance if @instance && !has_changes_to_save?

      @instance = FHIR.from_contents(json)
    end

    validate :validate_fhir_json

    before_validation :_to_fhir_json
    after_find :_from_fhir_json
  end
  # rubocop:enable Metrics/BlockLength
end
