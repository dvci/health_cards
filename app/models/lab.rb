class Lab < ApplicationRecord
    has_many :lab_result, dependent: :restrict_with_exception
  
    default_scope { order(:name) }
  end