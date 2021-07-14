# frozen_string_literal: true

class Vaccine < ApplicationRecord
  CVX = 'http://hl7.org/fhir/sid/cvx'

  has_many :immunizations, dependent: :restrict_with_exception

  default_scope { order(:name) }

end
