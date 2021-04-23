# frozen_string_literal: true

module HealthCards
  # Issue Health Cards based on a stored private key
  class Issuer
    attr_reader :url, :key

    # Create an Issuer
    #
    # @param key [HealthCards::PrivateKey] the private key used for signing issued health cards
    def initialize(key:, url: nil)
      @url = url
      PrivateKey.enforce_valid_key_type!(key)
      self.key = key
    end

    # Create a HealthCard from the supplied FHIR bundle
    #
    # @param bundle [FHIR::Bundle, String] the FHIR bundle used as the Health Card payload
    def create_health_card(bundle, credential_type: VerifiableCredential)
      raise HealthCards::MissingPrivateKey if key.nil?

      vc = credential_type.new(url, bundle)

      jws = issue_jws(vc.compress_credential)
      HealthCards::HealthCard.new(verifiable_credential: vc, jws: jws)
    end

    # Create a JWS for a given payload
    #
    # @param payload [Object] any object that supports to_s
    def issue_jws(payload)
      JWS.new(header: jws_header, payload: payload.to_s, key: key)
    end

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    def key=(key)
      PrivateKey.enforce_valid_key_type!(key)

      @key = key
    end

    # Returns the public key matching this issuer's
    # private key as a JWK KeySet JSON string useful for .well-known endpoints
    # @return [String] JSON string in JWK standard
    def to_jwk
      KeySet.new(key.public_key).to_jwk
    end

    private

    def jws_header
      { 'zip' => 'DEF', 'alg' => 'ES256', 'kid' => key.public_key.kid }
    end
  end
end
