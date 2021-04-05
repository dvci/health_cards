# frozen_string_literal: true

# Ties together FHIR models, HealthCard and Rails to create
# COVID Health Card IG complianct payloads
class CovidHealthCard < HealthCards::Card
  attr_reader :url, :patient

  PATIENT_MIN_ATTRIBUTES = %w[name birthDate].freeze # Add address
  IMM_MIN_ATTRIBUTES = %w[status vaccineCode patient occurrenceDateTime].freeze

  def initialize(patient, &url_handler)
    @patient = patient
    @url_handler = url_handler

    key = Rails.application.config.hc_key
    super(payload: vc, private_key: key, public_key: key.public_key)
  end

  def bundle
    return @bundle if @bundle

    @bundle ||= FHIR::Bundle.new(type: 'collection', entry: bundle_entries)
  end

  def vc
    return @vc if @vc

    @vc ||= HealthCards::VerifiableCredential.new(@url_handler.call, bundle.to_hash).compress_credential
  end

  def to_json(*_args)
    { verifiableCredential: [to_jws] }
  end

  def chunks
    HealthCards::Chunking.generate_qr_chunks vc.to_s
  end

  private

  def bundle_entries
    return @bundle_entries if @bundle_entries

    patient_url = @url_handler.call(patient)
    patient_entry = min_json(@patient, patient_url, PATIENT_MIN_ATTRIBUTES)
    immunization_entries = @patient.immunizations.map do |imm|
      imm_json = min_json(imm, @url_handler.call(imm), IMM_MIN_ATTRIBUTES)
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
