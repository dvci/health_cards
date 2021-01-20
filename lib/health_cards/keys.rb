# frozen_string_literal: true

require 'openssl'
require 'jose'

# Methods to generate signing/encryption keys
module Keys
  def generate_key
    key = OpenSSL::PKey::EC.generate('prime256v1')
    jwk = JOSE::JWK.from_key key
    jwk_map = jwk.to_map
    public_jwk = {
      kty: jwk_map.get('kty'),
      crv: jwk_map.get('crv'),
      x: jwk_map.get('x'),
      y: jwk_map.get('y')
    }
    private_jwk = {
      **public_jwk,
      d: jwk_map.get('d')
    }

    {
      key: key,
      publicJwk: public_jwk,
      privateJwk: private_jwk
    }
  end
end
