# frozen_string_literal: true

require 'openssl'
require 'date'
require 'base64'
require 'digest'
require 'json'

# Methods that allow signing and verifying digital signatures
module DigitalSignature
  # https://w3c-ccg.github.io/lds-ecdsa-secp256k1-2019/
  def key
    @key ||= OpenSSL::PKey::EC.generate('secp256k1') # prime256v1 for JWT (ES256) I think
  end

  # https://stackoverflow.com/questions/42070180/export-public-key-to-base64-in-ruby
  def public_key
    Base64.urlsafe_encode64(key.public_key.to_bn.to_s(2), padding: false)
  end

  def digest
    @digest ||= OpenSSL::Digest.new('SHA256')
  end

  def sign(data = string)
    key.sign(digest, data)
  end

  def verify(signature, data)
    key.verify(digest, signature, data)
  end

  # https://w3c-ccg.github.io/ld-proofs/#linked-data-proof-overview
  def proof(data)
    {
      type: 'EcdsaSecp256k1VerificationKey2019',
      created: DateTime.now.to_s,
      proofPurpose: 'assertionMethod',
      verificationMethod: 'did:ion:1234#keys-1',
      jws: jws(data)
    }
  end

  # JSON Web Signature (JWS): https://tools.ietf.org/html/rfc7515
  # JSON Web Signature (JWS) Unencoded Payload Option: https://tools.ietf.org/html/rfc7797
  def jws(payload)
    header = {
      alg: 'ES256',
      typ: 'application/json' # https://github.com/w3c/vc-data-model/issues/421
    }.to_json
    puts header
    header_payload = [encode(header), encode(payload.to_json)].join('.')
    puts header_payload
    digest = Digest::SHA2.hexdigest header_payload
    signature = encode sign(digest)
    [header_payload, signature].join('.')
  end

  # https://tools.ietf.org/html/rfc7515#section-2
  # See Base64url Encoding
  def encode(data)
    Base64.urlsafe_encode64(data.to_s, padding: false)
  end
end
