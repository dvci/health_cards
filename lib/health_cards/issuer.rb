# frozen_string_literal: true

require_relative 'file_key_store'
require 'json/jwk'
require 'base64'
require 'json'

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

  # Handle JWS with non-JSON Payloads
  class JWS

    def initialize(key, payload)
      @key = key
      @payload = payload
    end

    def thumbprint
      @thumbprint ||= @key.to_jwk.thumbprint
    end

    def jws_signature
      signature = @key.dsa_sign_asn1(jws_payload)
      encode(signature)
    end

    def jose_header
      encode(
        JSON.generate({
                        zip: "DEF",
                        alg: "ES256",
                        kid: thumbprint
                      }
        )
      )
    end

    def jws_payload
      encode(@payload)
    end

    def encode(data)
      Base64.urlsafe_encode64(data, padding: false).gsub("\n", "")
    end

    def decode(data)
      Base64.urlsafe_decode64(data)
    end

    def jws
      [jose_header, jws_payload, jws_signature].join('.')
    end

    def self.verify(public_key, jws)
      _, payload_to_verify, signature_to_verify = jws.split('.')
      verified = public_key.dsa_verify_asn1(payload_to_verify, decode(signature_to_verify))
      [verified, decode(payload_to_verify)]
    end
  end
end
