# frozen_string_literal: true

require 'openssl'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    BASE = { kty: 'EC', crv: 'P-256' }.freeze
    DIGEST = OpenSSL::Digest.new('SHA256')

    # Checks if obj is the the correct key type or nil
    # @param obj Object that should be of same type as caller or nil
    # @param allow_nil Allow/Disallow key to be nil
    def self.enforce_valid_key_type!(obj, allow_nil:  false)
      raise InvalidKeyException.new(self, obj) unless obj.is_a?(self) || (allow_nil && obj.nil?)
    end

    def initialize(ec_key)
      @key = ec_key
    end

    def to_json(*_args)
      to_jwk.to_json
    end

    def to_jwk
      coordinates.merge(kid: kid, use: 'sig', alg: 'ES256')
    end

    def kid
      Base64.urlsafe_encode64(DIGEST.digest(coordinates.except(:d).to_json), padding: false)
    end

    def coordinates
      unless @coordinates
        coor = @key.private_key? ? { d: @key.private_key.to_s(16) } : {}
        key_hex = @key.public_key.to_bn.to_s(16)
        xy = { x: key_hex[2..65], y: key_hex[66..130] }
        @coordinates = coor.merge(xy).transform_values do |val|
          Base64.urlsafe_encode64([val].pack('H*'), padding: false)
        end
      end
      BASE.merge(@coordinates)
    end
  end
end
