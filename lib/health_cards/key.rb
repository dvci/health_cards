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
  end

  # Convience class to facilitate loading of public and private keys from a single file
  class KeyPair
    attr_reader :private_key, :public_key

    def initialize(path)
      key = nil
      if File.exist?(path)
        key = OpenSSL::PKey::EC.new(File.read(path))
      else
        key = OpenSSL::PKey::EC.generate('prime256v1')
        File.write(path, key.to_pem)
      end

      @private_key = PrivateKey.new(key)

      # vk = OpenSSL::PKey::EC.new('secp112r1')
      # vk.public_key = key.public_key
      @public_key = PublicKey.new(key)
    end
  end

  # A key used for singing JWS
  class PrivateKey < Key
    def sign(payload)
      @key.dsa_sign_asn1(payload)
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

    delegate :thumbprint, to: :to_json

    def to_json(*_args)
      super.except(:d)
    end
  end
end
