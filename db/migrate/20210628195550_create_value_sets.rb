class CreateValueSets < ActiveRecord::Migration[6.1]
  def change
    create_table :value_sets do |t|
      t.string :oid
      t.string :codes
      t.timestamps
    end
  end
end
