# frozen_string_literal: true

module HealthCards
  # Verifiers can validate HealthCards using public keys
  class Verifier
    attr_reader :keys
    attr_accessor :resolve_keys

    # Create a new Verifier
    #
    # @param keys [HealthCards::KeySet, HealthCards::Key, nil]
    def initialize(keys: nil)
      @keys = case keys
              when KeySet
                keys
              when Key
                KeySet.new(keys)
              else
                KeySet.new
              end
    end

    # Add a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to add
    def add_keys(key)
      @keys.add_keys(key)
    end

    # Remove a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to remove
    def remove_keys(key)
      @keys.remove_keys(key)
    end

    # Verify a HealthCard
    #
    # @param verifiable [HealthCards::HealthCard, HealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def verify(verifiable)
      # TODO: This needs better logic to make sure the public key is correct and check for key resolution
      jws = case verifiable
            when JWS
              verifiable
            when String
              JWS.from_jws(verifiable)
            else
              raise ArgumentError, 'Expected either a HealthCards::JWS or String'
            end

      resolve_key(jws)
      key = keys.find_key(jws.kid)
      raise MissingPublicKey, 'Verifier does not contain public key that is able to verify this signature' unless key

      jws.public_key = key
      jws.verify
    end

    def resolve_key(jws)
      return unless (resolve_keys? && @keys.find_key(jws.kid).nil?)

      res = Net::HTTP.get(URI(public_key_url(jws)))
      add_keys(HealthCards::KeySet.from_jwks(res))
    end

    def resolve_keys?
      resolve_keys
    end

    private

    # The location of the JWKS containing the public key for the provided JWS
    #
    # @param jws [String, HealthCards::JWS] The JWS
    def public_key_url(jws)
      "#{HealthCard.from_jws(jws.to_s).issuer}/.well-known/jwks.json"
    end
  end
end
