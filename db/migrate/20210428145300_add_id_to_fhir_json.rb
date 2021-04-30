# frozen_string_literal: true

# Sets ID in existing FHIR-based records
class AddIdToFHIRJson < ActiveRecord::Migration[6.1]
  # https://guides.rubyonrails.org/v4.1/migrations.html#using-models-in-your-migrations
  # https://rails.rubystyle.guide/#define-model-class-migrations

  class MigrationPatient < ActiveRecord::Base
    self.table_name = :patients
    def set_fhir_id
      json.id = id
      save!
    end
  end

  class MigrationImmunization < ActiveRecord::Base
    self.table_name = :immunizations
    def set_fhir_id
      json.id = id
      save!
    end
  end

  def change
    MigrationPatient.all.each { |pat| pat.set_fhir_id }
    MigrationImmunization.all.each { |imm| imm.set_fhir_id }
  end
end
