# frozen_string_literal: true

# Maps FHIR Immunization to Web UI. Represents a dose of an immunization, actual
# vaccine info is stored in Vaccine. These are composited when mapping to FHIR
class Immunization < ApplicationRecord
  # include FHIRJsonStorage

  attribute :occurrence, :datetime
  attribute :lot_number, :string

  belongs_to :patient
  belongs_to :vaccine

  serialize :json, FHIR::Immunization

  validates :occurrence, presence: true
  validates :vaccine, presence: true
  validates :patient, presence: true

  def lot_number
    json.lotNumber
  end

  def lot_number=(lnum)
    json.lotNumber = lnum
    super(lnum)
  end

  def occurrence
    json.occurrenceDateTime
  end

  def occurrence=(occ)
    json.occurrenceDateTime = occ
    super(occ)
  end

  def vaccine=(vax)
    json.vaccineCode = vax.code
    super(vax)
  end
end
