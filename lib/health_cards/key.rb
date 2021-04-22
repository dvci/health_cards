# frozen_string_literal: true

require 'openssl'

module HealthCards
  # Methods to generate signing keys and jwk
  class Key
    BASE = { kty: 'EC', crv: 'P-256' }.freeze
    DIGEST = OpenSSL::Digest.new('SHA256')

    def initialize(ec_key)
      @key = ec_key
    end

    def to_json(*_args)
      to_jwk.to_json
    end

    def to_jwk
      coordinates.merge(thumbprint: thumbprint, use: 'sig', alg: 'ES256')
    end

    def thumbprint
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
