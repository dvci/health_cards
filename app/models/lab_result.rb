class LabResult < ApplicationRecord
    attribute :effective, :date
    attribute :lab, :string
  
    belongs_to :patient  

    serialize :json, FHIR::LabResult
  
    validates :effective, presence: true
    validates :lab, presence: true
    validates :patient, presence: true


  after_initialize do
    json.status ||= 'completed'
  end

  def effective
    from_fhir_time(json.effectiveDateTime)
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

#   def lab_code=(lc)
#     code = Lab.find(lc).code
#     update_lab_code(code)
#     super(lc)
#   end

#   def vaccine=(lab)
#     update_lab_code(lab.code)
#     super(lab)
#   end

end
