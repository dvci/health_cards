class CreateLabResults < ActiveRecord::Migration[6.1]
  def change
    create_table :lab_results do |t|
      t.references :patient
      t.string :json

      t.timestamps
    end
  end
end
