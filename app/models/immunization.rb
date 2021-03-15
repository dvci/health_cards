# frozen_string_literal: true

# Maps FHIR Immunization to Web UI. Represents a dose of an immunization, actual
# vaccine info is stored in Vaccine. These are composited when mapping to FHIR
class Immunization < ApplicationRecord
  include FHIRJsonStorage

  attribute :occurrence, :datetime
  attribute :lot_number, :string

  belongs_to :patient
  belongs_to :vaccine

  validates :occurrence, presence: true
  validates :vaccine, presence: true
  validates :patient, presence: true

  def from_fhir_json(patient)
    {
      occurrence: patient.occurrenceDateTime,
      lot_number: patient.lotNumber
    }
  end

  def to_fhir_json
    {
      vaccineCode: {
	coding: [{ system: 'http://hl7.org/fhir/sid/cvx', code: vaccine.code }]
      },
      status: 'completed',
      occurrenceDateTime: occurrence,
      lotNumber: lot_number,
      patient: { reference: "Patient/#{patient_id}" }
    }
  end
end
