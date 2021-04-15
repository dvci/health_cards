# frozen_string_literal: true

module HealthCardsHelper
  def create_patient_from_jws(jws_payload)
    bundle = FHIR.from_contents(jws_payload['vc']['credentialSubject']['fhirBundle'].to_json)
    patient_entry = bundle.entry.find { |e| e.resource.is_a?(FHIR::Patient) }
    return nil if patient_entry.nil?

    patient = Patient.new(json: patient_entry.resource)
    create_immunizations(patient, bundle)
    patient
  end

  private

  def create_immunizations(pat, bundle)
    immunizations = bundle.entry.select { |e| e.resource.is_a?(FHIR::Immunization) }
    vaccine_id_map = {
      '207': 1,
      '208': 2,
      '212': 3
    }

    immunizations.each do |i|
      immunization_resource = i.resource
      pat.immunizations.new({
                              vaccine_id: vaccine_id_map[immunization_resource.vaccineCode.coding[0].code.to_sym],
                              lot_number: immunization_resource.lotNumber,
                              occurrence: immunization_resource.occurrenceDateTime
                            })
    end
  end
end
