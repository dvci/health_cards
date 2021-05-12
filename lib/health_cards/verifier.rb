# frozen_string_literal: true

require 'net/http'

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
      verify_using_key_set(verifiable)
    end

    # Verify Health Card with given KeySet
    #
    # @param verifiable [HealthCards::JWS, String] the health card to verify
    # @param key_set [HealthCards::KeySet, nil] the KeySet from which keys should be taken or added
    # @param resolve_keys [Boolean] if keys should be resolved
    # @return [Boolean]
    def self.verify_using_key_set(verifiable, key_set = nil, resolve_keys = true)
      jws = JWS.from_jws(verifiable)
      key_set ||= HealthCards::KeySet.new
      key_set.add_keys(resolve_key(jws)) if resolve_keys && key_set.find_key(jws.kid).nil?

      key = key_set.find_key(jws.kid)
      raise MissingPublicKey, 'Verifier does not contain public key that is able to verify this signature' unless key

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
      self.class.verify_using_key_set(verifiable, keys, resolve_keys?)
    end

    def resolve_keys?
      resolve_keys
    end
  end
end
