# frozen_string_literal: true

class Vaccine < ApplicationRecord
  CVX = 'http://hl7.org/fhir/sid/cvx'

  has_many :immunizations, dependent: :restrict_with_exception

  default_scope { order(:name) }

  def self.seed
    Vaccine.find_or_create_by(code: '207') do |vaccine|
      vaccine.name = 'Moderna COVID-19 Vaccine'
      vaccine.doses_required = 2
    end

    Vaccine.find_or_create_by(code: '208') do |vaccine|
      vaccine.name = 'Pfizer COVID-19 Vaccine'
      vaccine.doses_required = 2
    end

    Vaccine.find_or_create_by(code: '212') do |vaccine|
      vaccine.name = 'Janssen COVID-19 Vaccine'
      vaccine.doses_required = 1
    end
  end
end
