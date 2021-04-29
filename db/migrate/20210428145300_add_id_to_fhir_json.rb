# frozen_string_literal: true

# Sets ID in existing FHIR-based records
class AddIdToFHIRJson < ActiveRecord::Migration[6.1]
  def change
    Patient.all.each { |pat| pat.set_fhir_id }
    Immunization.all.each { |imm| imm.set_fhir_id }
  end
end
