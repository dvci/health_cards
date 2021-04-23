# frozen_string_literal: true

# Ties together FHIR models, HealthCard and Rails to create
# COVID Health Card IG complianct payloads
class CovidHealthCard < HealthCards::HealthCard
  attr_reader :url, :patient

  PATIENT_MIN_ATTRIBUTES = %w[name birthDate].freeze # Add address
  IMM_MIN_ATTRIBUTES = %w[status vaccineCode patient occurrenceDateTime].freeze

  def initialize(patient, &url_handler)
    bundle = FHIR::Bundle.new(type: 'collection', entry: bundle_entries(patient, url_handler))
    vc = HealthCards::VerifiableCredential.new(url_handler.call, bundle)
    jws = Rails.application.config.issuer.issue_jws(vc.compress_credential)
    super(verifiable_credential: vc, jws: jws)
  end

  private

  def bundle_entries(patient, url_handler)
    return @bundle_entries if @bundle_entries

    patient_url = url_handler.call(patient)
    patient_entry = min_json(patient, patient_url, PATIENT_MIN_ATTRIBUTES)

    immunization_entries = patient.immunizations.map do |imm|
      imm_json = min_json(imm, url_handler.call(imm), IMM_MIN_ATTRIBUTES)
      imm_json.resource.patient.reference = patient_url
      imm_json
    end
    @bundle_entries ||= [patient_entry] + immunization_entries
  end

  def min_json(fhir_record, url, min_json_attributes)
    atts = ['resourceType'] + min_json_attributes
    minified = fhir_record.to_json.delete_if { |k, _v| atts.exclude?(k) }
    FHIR::Bundle::Entry.new(fullUrl: url, resource: minified)
  end
end
