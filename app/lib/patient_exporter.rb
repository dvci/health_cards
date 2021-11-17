# frozen_string_literal: true

class PatientExporter
  # def initialize(patient)
  #   @patient = patient
  # end

  # def to_fhir
  #   health_card.resource(type: FHIR::Patient).to_json
  # end

  # def qr_code_image(ordinal)
  #   code = qr_codes.code_by_ordinal(ordinal)
  #   return unless code

  #   code.image.to_s
  # end

  # # TODO: update when we support different types of COVID health cards
  # def issue(fhir_params)
  #   HealthCards::Exporter.issue(fhir_params) do |types|
  #     HealthCards::COVIDPayload.supports_type?(types) ? jws : nil
  #   end
  # end

  # def health_card
  #   issuer = Rails.application.config.issuer
  #   @health_card ||= issuer.issue_health_card(@patient.to_bundle(issuer.url), type: HealthCards::COVIDImmunizationPayload)
  # end
end
