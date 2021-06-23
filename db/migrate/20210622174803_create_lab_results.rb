class CreateLabResults < ActiveRecord::Migration[6.1]
  def change
    create_table :lab_results do |t|

      t.timestamps
    end
  end
end
