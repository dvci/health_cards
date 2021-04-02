# frozen_string_literal: true

require 'openssl'
require 'json/jwt'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    class << self
      def load_file(path)
        key = nil
        if File.exist?(path)
          key = OpenSSL::PKey::EC.new(File.read(path))
        else
          key = OpenSSL::PKey::EC.generate('prime256v1')
          File.write(path, key.to_pem)
        end
        Key.new(key)
      end

      def load_url
        # TODO
      end

      def load_string(signature)
        byebug
      end
    end

    def initialize(key)
      @key = key
    end

    def thumbprint
      @key.to_jwk.thumbprint
    end

    def sign(payload)
      signing_key.dsa_sign_asn1(payload)
    end

    def verify(payload, signature)
      signing_key.dsa_verify_asn1(payload, signature)
    end

    def signing_key
      @signing_key ||= @key
    end

    def public_key
      @public_key ||= signing_key.public_key
    end

    def to_json(*_args)
      @jwks ||= JSON::JWK::Set.new(keys: [signing_key.to_jwk(use: 'sig', alg: 'ES256').except(:d)]).as_json
    end
    
  end
end