# frozen_string_literal: true

require 'fhir_models'

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

    # Create a Payload from the supplied FHIR bundle
    #
    # @param bundle [FHIR::Bundle, String] the FHIR bundle used as the Health Card payload
    # @return [Payload::]
    def create_payload(bundle, type: Payload)
      type.new(issuer: url, bundle: bundle)
    end

    # Create a JWS for a given payload
    #
    # @param bundle [FHIR::Bundle] A FHIR::Bundle that will form the payload of the JWS object
    # @param type [Class] A subclass of HealthCards::Card that processes the bundle according to a specific IG.
    # Leave blank for default SMART Health Card behavior
    # @return [HealthCards::JWS] An instance of JWS using the payload and signed by the issuer's private key
    def issue_jws(bundle, type: Payload)
      card = create_payload(bundle, type: type)
      JWS.new(header: jws_header, payload: card.to_s, key: key)
    end

    def issue_health_card(bundle, type: Payload)
      jws = issue_jws(bundle, type: type)
      HealthCards::HealthCard.new(jws)
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
