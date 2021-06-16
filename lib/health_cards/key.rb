# frozen_string_literal: true

require 'openssl'
require 'base64'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    BASE = { kty: 'EC', crv: 'P-256' }.freeze
    DIGEST = OpenSSL::Digest.new('SHA256')

    # Checks if obj is the the correct key type or nil
    # @param obj Object that should be of same type as caller or nil
    # @param allow_nil Allow/Disallow key to be nil
    def self.enforce_valid_key_type!(obj, allow_nil: false)
      raise InvalidKeyError.new(self, obj) unless obj.is_a?(self) || (allow_nil && obj.nil?)
    end

    # Create a key from a JWK
    #
    # @param jwk_key [Hash] The JWK represented by a Hash
    # @return [HealthCards::Key] The key represented by the JWK
    def self.from_jwk(jwk_key)
      jwk_key = jwk_key.transform_keys(&:to_sym)
      group = OpenSSL::PKey::EC::Group.new('prime256v1')
      key = OpenSSL::PKey::EC.new(group)
      key.private_key = OpenSSL::BN.new(Base64.urlsafe_decode64(jwk_key[:d]), 2) if jwk_key[:d]
      public_key_bn = ['04'].pack('H*') + Base64.urlsafe_decode64(jwk_key[:x]) + Base64.urlsafe_decode64(jwk_key[:y])
      key.public_key = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(public_key_bn, 2))
      key.private_key? ? HealthCards::PrivateKey.new(key) : HealthCards::PublicKey.new(key)
    end

    def initialize(ec_key)
      @key = ec_key
    end

    def group
      @key.group
    end

    def to_json(*_args)
      to_jwk.to_json
    end

    def to_jwk
      coordinates.merge(kid: kid, use: 'sig', alg: 'ES256')
    end

    def kid
      Base64.urlsafe_encode64(DIGEST.digest(public_coordinates.to_json), padding: false)
    end

    def public_coordinates
      coordinates.slice(:crv, :kty, :x, :y)
    end

    def coordinates
      return @coordinates if @coordinates

      key_binary = @key.public_key.to_bn.to_s(2)
      coords = { x: key_binary[1, key_binary.length / 2],
                 y: key_binary[key_binary.length / 2 + 1, key_binary.length] }
      coords[:d] = @key.private_key.to_s(2) if @key.private_key?
      @coordinates = coords.transform_values do |val|
        Base64.urlsafe_encode64(val, padding: false)
      end.merge(BASE)
    end
  end
end
