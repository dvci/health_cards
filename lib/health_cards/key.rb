# frozen_string_literal: true

require 'openssl'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    BASE = { kty: 'EC', crv: 'P-256' }.freeze
    DIGEST = OpenSSL::Digest.new('SHA256')

    def initialize(key)
      @key = key
    end

    def to_json(*_args)
      to_jwk.to_json
    end

    def to_jwk
      required.merge(thumbprint: thumbprint, use: 'sig', alg: 'ES256')
    end

    def thumbprint
      Base64.urlsafe_encode64(DIGEST.digest(required.except(:d).to_json), padding: false)
    end

    # Represents a set of Public Keys
    class Set
      attr_reader :keys

      def initialize(*key_arr)
        @keys = key_arr
      end

      def to_json(*_args)
        { keys: keys.map(&:to_jwk) }.to_json
      end
    end

    def required
      BASE.merge(coordinates)
    end

    def coordinates
      return @coordinates if @coordinates

      coor = @key.private_key? ? { d: @key.private_key.to_s(16) } : {}
      key_hex = @key.public_key.to_bn.to_s(16)
      xy = { x: key_hex[2..65], y: key_hex[66..130] }
      @coordinates = coor.merge(xy).transform_values do |val|
        Base64.urlsafe_encode64([val].pack('H*'), padding: false)
      end
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
  end
end
