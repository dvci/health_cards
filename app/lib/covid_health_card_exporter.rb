# frozen_string_literal: true

class COVIDHealthCardExporter
  def initialize(patient)
    @patient = patient
  end

  def download
    HealthCards::Exporter.download([jws])
  end

  def qr_codes
    @qr_codes ||= HealthCards::Exporter.qr_codes(jws)
  end

  def qr_code_image(ordinal)
    code = qr_codes.code_by_ordinal(ordinal)
    return unless code

    code.image.to_s
  end

  def issue(fhir_params)
    err = validate_fhir_params(fhir_params)
    return err.to_json if err

    vcs = []

    types = extract_types(fhir_params)

    vcs << jws if HealthCards::COVIDHealthCard.supports_type?(*types)

    HealthCards::Exporter.issue(vcs)
  end

  def extract_types(fhir_params)
    fhir_params.parameter.map(&:valueUri).compact
  end

  def jws
    issuer = Rails.application.config.issuer
    @jws ||= issuer.issue_jws(@patient.to_bundle(issuer.url), type: HealthCards::COVIDHealthCard)
  end

  def validate_fhir_params(fhir_params)
    if fhir_params.nil?
      err_msg = 'Unable to find FHIR::Parameter JSON'
    elsif !fhir_params.valid?
      err_msg = fhir_params.validate.to_s
    else
      types = extract_types(fhir_params)
      err_msg = 'Invalid Parameter: Expected valueUri' if types.empty?
    end

    return unless err_msg

    iss = FHIR::OperationOutcome::Issue.new(severity: 'error', code: 'invalid', diagnostic: err_msg)
    FHIR::OperationOutcome.new(issue: iss)
  end
end
