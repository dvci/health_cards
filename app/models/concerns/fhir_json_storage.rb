# frozen_string_literal: true

# Enables models to act a shim around a FHIR JSON blob
module FhirJsonStorage
  include FHIR
  extend ActiveSupport::Concern

  included do
    # byebug

    def validate_fhir_json
      errors.each { |e| errors.add(:base, e) } unless @@resource_def.validates_resource?(fhir_instance)
    end

    def to_fhir_json
      fhir_resource = "FHIR::#{@@resource_name}".constantize.new(send(@@to))
      self.json = fhir_resource.to_json
    end

    def from_fhir_json
      assign_attributes(send(@@from, fhir_instance))
    end

    def fhir_instance
      return @instance if @instance && !has_changes_to_save?

      @instance = FHIR.from_contents(json)
    end

    validate :validate_fhir_json

    before_validation :to_fhir_json
    after_find :from_fhir_json
  end

  class_methods do
    def map_to_fhir(params = {})
      @@resource_name = params[:resource_name] || name
      @@resource_def = FHIR::Definitions.resource_definition(@@resource_name)
      @@to = params[:to]
      @@from = params[:from]
    end
  end
end
