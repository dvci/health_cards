# frozen_string_literal: true

require_relative 'file_key_store'

require 'json/jwk'

module HealthCards
  # Verifiable Credential Issuer
  #
  # https://www.w3.org/TR/vc-data-model/#issuer
  class Issuer
    def initialize(key_store)
      @key = key_store.load_or_create_key
    end

    def signing_key
      @signing_key ||= @key.to_jwk(use: 'sig', alg: 'ES256')
    end

    def public_key
      @public_key ||= signing_key.except(:d)
    end

    def sign(vcr, url)
      jwt = JSON::JWT.new(vcr.credential.merge(nbf: Time.zone.now, iss: url))
      jwt.sign(signing_key).to_s
    end

    def jwks
      @jwks ||= JSON::JWK::Set.new(keys: [public_key]).as_json
    end
  end
end
