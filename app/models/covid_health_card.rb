# frozen_string_literal: true

class CovidHealthCard
  attr_reader :vc, :url

  def initialize(patient, url)
    bundle = patient.to_bundle
    @url = url
    @vc = HealthCards::VerifiableCredential.new(bundle)
  end

  def jwt
    vc.jwt(url)
  end
end
