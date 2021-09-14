# frozen_string_literal: true

module HealthCardsHelper
  def create_patient_from_jws(jws_payload)
    bundle = FHIR.from_contents(jws_payload['vc']['credentialSubject']['fhirBundle'].to_json)
    patient_entry = bundle.entry.find { |e| e.resource.is_a?(FHIR::Patient) }
    return nil if patient_entry.nil?

    patient = Patient.new(json: patient_entry.resource)
    new_immunizations(patient, bundle)
    new_lab_result(patient, bundle)
    patient
  end

  private

  def new_immunizations(pat, bundle)
    immunizations = bundle.entry.select { |e| e.resource.is_a?(FHIR::Immunization) }
    immunizations.each do |i|
      immunization_resource = i.resource

      vax = Vaccine.find_by(code: immunization_resource.vaccineCode.coding[0].code) || Vaccine.create(
        code: immunization_resource.vaccineCode.coding[0].code, name: 'Unknown Vaccine'
      )
      pat.immunizations.new({
                              vaccine_id: vax.id,
                              lot_number: immunization_resource.lotNumber,
                              occurrence: immunization_resource.occurrenceDateTime
                            })
    end
  end

  def new_lab_result(patient, bundle)
    lab_results = bundle.entry.select { |e| e.resource.is_a?(FHIR::Observation) }
    lab_results.each do |i|
      lab_result_resource = i.resource
      patient.lab_results.new({
                                code: lab_result_resource.code.coding[0].code,
                                status: lab_result_resource.status,
                                result: lab_result_resource.valueCodeableConcept.coding[0].code,
                                effective: lab_result_resource.effectiveDateTime
                              })
    end
  end
end
