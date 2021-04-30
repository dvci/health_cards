# frozen_string_literal: true


# Sets ID in existing FHIR-based records
class AddIdToFHIRJson < ActiveRecord::Migration[6.1]
  # https://guides.rubyonrails.org/v4.1/migrations.html#using-models-in-your-migrations
  # https://rails.rubystyle.guide/#define-model-class-migrations
  #
  class MigrationFHIRSerializer
    def self.load(json)
      json ? FHIR.from_contents(json) : new
    end

    def self.dump(model)
      raise ActiveRecord::SerializationTypeMismatch unless model.class.module_parent == FHIR

      model.to_json
    end
  end

  class MigrateFHIRRecord
    serialize :json, MigrationFHIRSerializer

    def set_fhir_id
      json.id = id
      save!
    end
  end

  class MigrationPatient < MigrateFHIRRecord
    self.table_name = :patients
  end

  class MigrationImmunization < MigrateFHIRRecord
    self.table_name = :immunizations
  end

  def change
    MigrationPatient.all.each { |pat| pat.set_fhir_id }
    MigrationImmunization.all.each { |imm| imm.set_fhir_id }
  end
end
