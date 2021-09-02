# frozen_string_literal: true

class PatientExporter
  def initialize(patient)
    @patient = patient
  end

  def download
    HealthCards::Exporter.download([jws])
  end

  def qr_codes
    @qr_codes ||= HealthCards::Exporter.qr_codes(jws)
  end

  def to_fhir
    @patient.to_json
  end

  def qr_code_image(ordinal)
    code = qr_codes.code_by_ordinal(ordinal)
    return unless code

    code.image.to_s
  end

  # TODO: update when we support diffrent types of COVID health cards
  def issue(fhir_params)
    HealthCards::Exporter.issue(fhir_params) do |types|
      HealthCards::COVIDHealthCard.supports_type?(types) ? jws : nil
    end
  end

  def jws
    issuer = Rails.application.config.issuer
    @jws ||= issuer.issue_jws(@patient.to_bundle(issuer.url), type: HealthCards::COVIDImmunizationCard)
  end
end
