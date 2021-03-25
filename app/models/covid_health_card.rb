# frozen_string_literal: true

# Ties together FHIR models, HealthCard and Rails to create
# COVID Health Card IG complianct payloads
class CovidHealthCard
  attr_reader :url, :patient

  PATIENT_MIN_ATTRIBUTES = %w[name birthDate].freeze # Add address
  IMM_MIN_ATTRIBUTES = %w[status vaccineCode patient occurrenceDateTime].freeze

  def initialize(patient, url)
    @patient = patient
    @url = url
  end

  def bundle
    return @bundle if @bundle

    @bundle ||= FHIR::Bundle.new(type: 'collection', entry: bundle_entries)
  end

  def vc
    return @vc if @vc

    vc = HealthCards::VerifiableCredential.new(bundle)
    @vc ||= Rails.application.config.issuer.sign(vc, url)
  end

  def to_json(*_args)
    { verifiableCredential: [vc.to_s] }
  end

  private

  def bundle_entries
    return @bundle_entries if @bundle_entries

    patient_entry = min_json(@patient, PATIENT_MIN_ATTRIBUTES)
    immunization_entries = @patient.immunizations.map { |imm| min_json(imm, IMM_MIN_ATTRIBUTES) }
    @bundle_entries ||= [patient_entry] + immunization_entries
  end

  def min_json(fhir_record, min_json_attributes)
    atts = ['resourceType'] + min_json_attributes
    minified = fhir_record.to_json.delete_if { |k, _v| atts.exclude?(k) }
    FHIR::Bundle::Entry.new(resource: minified)
  end
end
