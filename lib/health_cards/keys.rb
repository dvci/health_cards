# frozen_string_literal: true

require 'openssl'
require 'jose'

# Methods to generate signing/encryption keys
module Keys
  def generate_signing_key(path = nil)
    key = JOSE::JWS.generate_key({ 'alg' => 'ES256' })
    save_key(key.to_key, path)
    key_to_jwk(key, 'sig')
  end

  def generate_encryption_key(path = nil)
    epk = JOSE::JWK.generate_key([:ec, 'P-256'])
    jwe = JOSE::JWE.from_map({ 'alg' => 'ECDH-ES', 'enc' => 'A256GCM', 'epk' => epk.to_map })
    key = jwe.generate_key
    save_key(key.to_key, path)
    key_to_jwk(key, 'enc')
  end

  def key_to_jwk(key, type)
    jwk_map = key.to_map
    jwk = {
      kty: jwk_map.get('kty'),
      kid: key.thumbprint,
      use: jwk_map.get('use'),
      alg: jwk_map.get('alg'),
      crv: jwk_map.get('crv'),
      x: jwk_map.get('x'),
      y: jwk_map.get('y')
    }

    jwk[:use] = type == 'sig' ? 'sig' : 'enc'
    jwk[:alg] = type == 'sig' ? 'ES256' : 'ECDH-ES'

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
  def load_key(path, type)
    file = File.open(path, 'r')
    pem = file.read
    key = JOSE::JWK.from_pem pem
    key_to_jwk(key, type)
  end
end
