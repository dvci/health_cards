# frozen_string_literal: true

module HealthCards
  # Logic for verifying a HealthCard JWS
  module Verification
    # Verify Health Card with given KeySet
    #
    # @param verifiable [HealthCards::JWS, String] the health card to verify
    # @param key_set [HealthCards::KeySet, nil] the KeySet from which keys should be taken or added
    # @param resolve_keys [Boolean] if keys should be resolved
    # @return [Boolean]
    def verify_using_key_set(verifiable, key_set = nil, resolve_keys = true)
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
    def resolve_key(jws)
      res = Net::HTTP.get(URI("#{HealthCard.from_jws(jws.to_s).issuer}/.well-known/jwks.json"))
      HealthCards::KeySet.from_jwks(res)
    end
  end
end
