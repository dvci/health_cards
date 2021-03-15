class CreateVaccines < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccines do |t|
      t.string :code
      t.string :name
      t.integer :doses_required

      t.timestamps
    end
  end
end
