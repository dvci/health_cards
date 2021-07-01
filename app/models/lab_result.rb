class LabResult < FHIRRecord
    attribute :effective, :date
    attribute :code, :string
    attribute :status, :string
  
    belongs_to :patient  

    serialize :json, FHIR::Observation
  
    validates :effective, presence: true
    validates :code, presence: true
    validates :patient, presence: true


  after_initialize do
    json.status ||= 'completed'
  end

  def effective
    from_fhir_time(json.effectiveDateTime)
  end

  def status
    json.status
  end

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

  def lab_code=(lc)
    code = Lab.find(lc).code
    update_lab_code(code)
    super(lc)
  end

  def vaccine=(lab)
    update_lab_code(lab.code)
    super(lab)
  end
private 

def update_lab_code(code)
  json.labCode ||= FHIR::CodeableConcept.new
  json.labCode.coding[0] = FHIR::Coding.new(system: 'http://loinc.org', code: code)
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
