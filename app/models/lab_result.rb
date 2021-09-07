# frozen_string_literal: true

class LabResult < FHIRRecord
  attribute :effective, :date
  attribute :code, :string
  attribute :result, :string
  attribute :status, :string

  belongs_to :patient

  serialize :json, FHIR::Observation

  STATUS = %w[final amended corrected].freeze

  validates :effective, presence: true
  validates :patient, presence: true
  validates :code, inclusion: { in: ValueSet::LAB_CODES.code_values, message: 'is not a valid lab code' }
  validates :result, inclusion: { in: ValueSet::RESULTS.code_values, message: 'is not a valid lab result' }
  validates :status, inclusion: { in: STATUS, message: 'is not a valid status' }

  def effective
    from_fhir_time(json.effectiveDateTime)
  end

  delegate :status, to: :json

  delegate :status=, to: :json

  def effective=(eff)
    super(eff)
    json.effectiveDateTime = to_fhir_time(attributes['effective'])
    attributes['effective']
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

  def result
    json.valueCodeableConcept&.coding&.first&.code
  end

  def result=(labc)
    update_result(labc)
    super(labc)
  end

  def code
    json.code&.coding&.first&.code
  end

  def code=(lab)
    update_code(lab)
    super(lab)
  end

  def name
    json.code.coding[0].display
  end

  def result_name
    json.valueCodeableConcept&.coding&.first&.display
  end

  private

  def update_result(code)
    json.valueCodeableConcept	||= FHIR::CodeableConcept.new
    json.valueCodeableConcept.coding = [ValueSet::RESULTS.find_code(code)]
  end

  def update_code(code)
    json.code ||= FHIR::CodeableConcept.new
    json.code.coding = [ValueSet::LAB_CODES.find_code(code)]
  end

  def update_patient_reference(pat)
    if pat
      json.subject ||= FHIR::Reference.new
      json.subject.reference = "Patient/#{pat.json.id}"
    else
      json.subject = nil
    end
  end
end
