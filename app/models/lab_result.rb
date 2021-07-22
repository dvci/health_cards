class LabResult < FHIRRecord
    attribute :effective, :date
    attribute :lab_code, :string
    attribute :status, :string
  
    belongs_to :patient
    
    serialize :json, FHIR::Observation
  
    validates :effective, presence: true
    validates :patient, presence: true
    validates :lab_code, presence: true 
    validates :status, presence: true


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
    lc = ValueSet.get_info_from_valueset
    #TODO: should be able to get the code here
    update_lab_code(lc)
    super(lc)
  end

  def lab_codes=(lab)
    update_lab_code(lab.code)
    super(lab)
  end
private 

def update_lab_code(code)
  json.lab_code ||= FHIR::CodeableConcept.new
  #json.lab_code.coding[0] = FHIR::Coding.new(system: 'http://loinc.org', code: code)
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
