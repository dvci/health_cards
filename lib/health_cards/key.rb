# frozen_string_literal: true

require 'openssl'
require 'json/jwt'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    def initialize(key)
      @key = key
    end

    def to_json(*_args)
      @key.to_jwk(use: 'sig', alg: 'ES256')
    end

    delegate :thumbprint, to: :to_json

    def to_jwk
      {
        kty: 'EC',
        use: 'sig',
        alg: 'ES256',
        crv: 'P-256'
      }
    end

    # Represents a set of Public Keys
    class Set
      attr_reader :keys

      def initialize(*key_arr)
        @keys = key_arr
      end

      def to_json(*_args)
        JSON::JWK::Set.new(keys: keys.map(&:to_json)).as_json
      end
    end

    private

    def encode(val)
      Base64.urlsafe_encode64(val.pack('H*'), padding: false)
    end
  end

  # A key used for singing JWS
  class PrivateKey < Key
    def self.from_file(path)
      pem = OpenSSL::PKey::EC.new(File.read(path))
      PrivateKey.new(pem)
    end

    def self.from_file!(path)
      if File.exist?(path)
        from_file(path)
      else
        key = OpenSSL::PKey::EC.generate('prime256v1')
        File.write(path, key.to_pem)
        PrivateKey.new(key)
      end
    end

    def sign(payload)
      @key.dsa_sign_asn1(payload)
    end

    def public_key
      return @public_key if @public_key

      pub = OpenSSL::PKey::EC.new('prime256v1')
      pub.public_key = @key.public_key
      @public_key = PublicKey.new(pub)
    end
  end

  # A key used for verifying JWS
  class PublicKey < Key
    def self.from_json(json)
      # TODO
    end

    def verify(payload, signature)
      @key.dsa_verify_asn1(payload, signature)
    end

    def to_json(*_args)
      super.except(:d)
    end
  end
end
