# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[6.1]
  def change
    create_table :patients do |t|
      t.string :json
      t.timestamps
    end
  end
end
