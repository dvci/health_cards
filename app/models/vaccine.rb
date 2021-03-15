# frozen_string_literal: true

class Vaccine < ApplicationRecord
  has_many :immunizations, dependent: :restrict_with_exception

  default_scope { order(:name) }
end
