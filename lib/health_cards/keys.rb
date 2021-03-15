# frozen_string_literal: true

require 'openssl'
require 'jose'

module HealthCards
  # Methods to generate signing keys and jwk
  module Keys
    def generate_signing_key(path = nil)
      key = JOSE::JWS.generate_key({ 'alg' => 'ES256' })
      save_key(key.to_key, path)
      key_to_jwk(key)
    end

    # Converts JOSE::JWK to formatted jwk
    # Returns OpenSSL key and public jwk
    def key_to_jwk(key)
      jwk_map = key.to_map
      jwk = {
        kty: jwk_map.get('kty'),
        kid: key.thumbprint,
        use: 'sig',
        alg: 'ES256',
        crv: jwk_map.get('crv'),
        x: jwk_map.get('x'),
        y: jwk_map.get('y')
      }

      {
        key: key.to_key,
        jwk: jwk
      }
    end

    def save_key(key, path)
      return if path.nil?

      file = File.open(path, 'w')
      file.write key.to_pem
      file.close
    end

    # Load key from pem file
    def load_key(path)
      file = File.open(path, 'r')
      pem = file.read
      key = JOSE::JWK.from_pem pem
      key_to_jwk(key)
    end
  end
end
