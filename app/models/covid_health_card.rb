# frozen_string_literal: true

# Ties together FHIR models, HealthCard and Rails to create
# COVID Health Card IG complianct payloads
class CovidHealthCard
  attr_reader :vc, :url

  def initialize(patient, url)
    bundle = patient.to_bundle
    vc = HealthCards::VerifiableCredential.new(bundle)
    @payload = Rails.application.config.issuer.sign(vc, url)
  end

  def to_json(*_args)
    { verifiableCredential: [@payload.to_s] }
  end
end
