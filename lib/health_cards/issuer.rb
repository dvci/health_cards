# frozen_string_literal: true

module HealthCards
  # Issue Health Cards based on a stored private key
  class Issuer

    attr_reader :url, :key

    # Create an Issuer
    #
    # @param key [HealthCards::PrivateKey] the private key used for signing issued health cards
    def initialize(url: nil, key: nil)
      @url = url
      self.key = key
    end

    # Create a HealthCard from the supplied FHIR bundle
    #
    # @param bundle [FHIR::Bundle, String] the FHIR bundle used as the Health Card payload
    def create_health_card(bundle)
      raise HealthCards::MissingPrivateKey if key.nil?
      vc = VerifiableCredential.new(@url, bundle)
      HealthCards::HealthCard.new(verifiable_credential: vc, key: key)
    end

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    def key=(key)
      raise HealthCards::MissingPrivateKey unless key.is_a?(PrivateKey) || key.nil?

      @key = key
    end
  end
end
