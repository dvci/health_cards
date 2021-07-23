class LabResult < FHIRRecord
    attribute :effective, :date
    attribute :code, :string
    attribute :result, :string
    attribute :status, :string
  
    belongs_to :patient
    
    serialize :json, FHIR::Observation
  
    validates :effective, presence: true
    validates :patient, presence: true
    validates :code, presence: true
    validates :result, presence: true 
    validates :status, presence: true

    STATUS = %w(final amended corrected)

  def effective
    from_fhir_time(json.effectiveDateTime)
  end

  def status
    json.status
  end

  def status=(stat)
    json.status = stat
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

  def result
    json.valueCodeableConcept&.coding&.first&.code
  end

  def result=(lc)
    update_result(lc)
    super(lc)
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

  def result
    json.valueCodeableConcept.coding[0].display
    
  end

private 

  def update_result(code)
    json.valueCodeableConcept	||= FHIR::CodeableConcept.new(coding: [ValueSet::RESULTS.find_by_code(code)])
  end

  def update_code(code)
    json.code	||= FHIR::CodeableConcept.new(coding: [ValueSet::LAB_CODES.find_by_code(code)])
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
