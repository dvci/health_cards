# frozen_string_literal: true

module HealthCards
  # Verifiers can validate HealthCards using public keys
  class Verifier
    attr_reader :keys
    attr_accessor :resolve_keys

    # Verify a HealthCard
    #
    # This method _always_ uses key resolution and does not depend on any cached keys
    #
    # @param verifiable [HealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def self.verify(verifiable)
      jws = JWS.from_jws(verifiable)
      key_set = resolve_key(jws)
      key = key_set.find_key(jws.kid)
      jws.public_key = key
      jws.verify
    end

    # Resolve a key
    # @param jws [HealthCards::JWS, String] The JWS for which to resolve keys
    # @return [HealthCards::KeySet]
    def self.resolve_key(jws)
      res = Net::HTTP.get(URI("#{HealthCard.from_jws(jws.to_s).issuer}/.well-known/jwks.json"))
      HealthCards::KeySet.from_jwks(res)
    end

    # Create a new Verifier
    #
    # @param keys [HealthCards::KeySet, HealthCards::Key, nil] keys to use when verifying Health Cards
    # @param resolve_keys [Boolean] Enables or disables key resolution
    def initialize(keys: nil, resolve_keys: true)
      @keys = case keys
              when KeySet
                keys
              when Key
                KeySet.new(keys)
              else
                KeySet.new
              end

      self.resolve_keys = resolve_keys
    end

    # Add a key to use when verifying
    #
    # @param key [HealthCards::Key, HealthCards::KeySet] the key to add
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
    # @param verifiable [HealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def verify(verifiable)
      # TODO: This needs better logic to make sure the public key is correct and check for key resolution
      jws = JWS.from_jws(verifiable)

      add_keys(self.class.resolve_key(jws)) if resolve_keys? && @keys.find_key(jws.kid).nil?

      key = keys.find_key(jws.kid)
      raise MissingPublicKey, 'Verifier does not contain public key that is able to verify this signature' unless key

      jws.public_key = key
      jws.verify
    end

    def resolve_keys?
      resolve_keys
    end
  end
end
