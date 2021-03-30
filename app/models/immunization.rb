# frozen_string_literal: true

# Maps FHIR Immunization to Web UI. Represents a dose of an immunization, actual
# vaccine info is stored in Vaccine. These are composited when mapping to FHIR
class Immunization < FHIRRecord
  # include FHIRJsonStorage

  attribute :occurrence, :date
  attribute :lot_number, :string

  belongs_to :patient
  belongs_to :vaccine

  serialize :json, FHIR::Immunization

  validates :occurrence, presence: true
  validates :vaccine, presence: true
  validates :patient, presence: true

  after_initialize do
    json.status ||= 'completed'
  end

  def lot_number
    json.lotNumber
  end

  def lot_number=(lnum)
    json.lotNumber = lnum if lnum.present?
    super(lnum)
  end

  def occurrence
    from_fhir_time(json.occurrenceDateTime)
  end

  def occurrence=(occ)
    super(occ)
    json.occurrenceDateTime = to_fhir_time(attributes['occurrence'])
    attributes['occurrence']
  end

  def patient_id=(pid)
    update_patient_reference(pid)
    super(pid)
  end

  def patient=(pat)
    update_patient_reference(pat.id)
    super(pat)
  end

  def vaccine_id=(vid)
    code = Vaccine.find(vid).code
    update_vax_code(code)
    super(vid)
  end

  def vaccine=(vax)
    update_vax_code(vax.code)
    super(vax)
  end

  private

  def update_vax_code(code)
    json.vaccineCode ||= FHIR::CodeableConcept.new
    json.vaccineCode.coding[0] = FHIR::Coding.new(system: 'http://hl7.org/fhir/sid/cvx', code: code)
  end

  def update_patient_reference(pid)
    json.patient ||= FHIR::Reference.new
    json.patient.reference = "Patient/#{pid}"
  end
end
