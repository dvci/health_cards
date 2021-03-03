# frozen_string_literal: true

require 'openssl'
require 'jose'

# Methods to generate signing/encryption keys
module Keys
  # Generate new key and save if path provided
  def generate_key(path = nil)
    key = OpenSSL::PKey::EC.generate('prime256v1')
    unless path.nil?
      file = File.open(path, 'w')
      file.write key.to_pem
      file.close
    end
    key_jwk key
  end

  def key_jwk(key)
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

  # Load key from pem file
  def load_key(path)
    file = File.open(path, 'r')
    pem = file.read
    key = OpenSSL::PKey::EC.new pem
    key_jwk key
  end
end
