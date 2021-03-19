class CreateImmunizations < ActiveRecord::Migration[6.1]
  def change
    create_table :immunizations do |t|
      t.references :patient
      t.references :vaccine
      t.string :json

      t.timestamps
    end
  end
end
