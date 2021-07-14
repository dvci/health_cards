# frozen_string_literal: true

require 'serializers/fhir_serializer'

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
    pat = Patient.find(pid) if pid
    update_patient_reference(pat)
    super(pid)
  end

  def patient=(pat)
    update_patient_reference(pat)
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

  def self.create_from_resource!(fhir_resource, patient = nil)
    raise StandardError unless fhir_resource.resourceType.upcase == 'IMMUNIZATION'
    raise NotImplementedError if fhir_resource.vaccineCode.coding[0].system != Vaccine::CVX

    vax = Vaccine.find_by!(fhir_resource.vaccineCode.coding[0].code)
    occurred_at = DateTime.parse(fhir_resource.occurrenceDateTime)
    Immunization.new({ vaccine: vax, occurrence: occurred_at, patient: patient })
  end
  
  private

  def update_vax_code(code)
    json.vaccineCode ||= FHIR::CodeableConcept.new
    json.vaccineCode.coding[0] = FHIR::Coding.new(system: 'http://hl7.org/fhir/sid/cvx', code: code)
  end

  def update_patient_reference(pat)
    if pat
      json.patient ||= FHIR::Reference.new
      json.patient.reference = "Patient/#{pat.json.id}"
    else
      json.patient = nil
    end
  end

end
