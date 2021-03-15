# frozen_string_literal: true

require 'concerns/fhir_json_storage'

# Patient model to map our input form to FHIR
class Patient < ApplicationRecord
  include FhirJsonStorage

  map_to_fhir(to: :set_fhir_json, from: :get_fhir_json)

  attribute :given, :string
  attribute :family, :string
  attribute :gender, :string
  attribute :phone, :string
  attribute :email, :string
  attribute :birth_date, :date

  GENDERS = FHIR::Patient::METADATA['gender']['valid_codes']['http://hl7.org/fhir/administrative-gender']

  validates :gender, inclusion: { in: GENDERS, allow_nil: true }

  def full_name
    [given, family].join(' ') if given || family
  end

  private

  def get_fhir_json(patient)
    name = patient.name.first
    given, family = nil
    if name
      given  = name.given.first
      family = name.family
    end
    {
      given: given,
      family: family,
      gender: patient.gender,
      email: patient.telecom.find { |t|  t.system == 'email' }.value,
      phone: patient.telecom.find { |t|  t.system == 'phone' }.value,
      birth_date: patient.birthDate
    }
  end

  def set_fhir_json
    {
      name: [{ given: [given], family: family }],
      gender: gender,
      telecom: [{ system: 'phone', value: phone },
                { system: 'email', value: email }],
      birthDate: birth_date
    }
  end
end
