# frozen_string_literal: true

require_relative 'file_key_store'

module HealthCards
  # Verifiable Credential Issuer
  #
  # https://www.w3.org/TR/vc-data-model/#issuer
  class Issuer
    def initialize(key_store)
      @key = key_store.load_or_create_key
    end

    def signing_key
      @signing_key ||= JSON::JWK.new(@key, use: 'sig', alg: 'ES256')
    end

    def public_key
      @public_key ||= signing_key.except(:d)
    end

    def jwks
      @jwks ||= {
	keys: [public_key]
      }
    end
  end
end
