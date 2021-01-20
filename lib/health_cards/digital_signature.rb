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
    key.public_key.to_bn.to_s(16).downcase
  end

  def digest
    @digest ||= OpenSSL::Digest.new('SHA256')
  end

  def sign(data = string)
    key.dsa_sign_asn1(data)
  end

  def verify(pub_key_hex, signature, data)
    group = OpenSSL::PKey::EC::Group.new('secp256k1')
    key_group = OpenSSL::PKey::EC.new(group)
    public_key_bn = OpenSSL::BN.new(pub_key_hex, 16)
    pub_key = OpenSSL::PKey::EC::Point.new(group, public_key_bn)
    key_group.public_key = pub_key
    key_group.dsa_verify_asn1(data, decode(signature))
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
    header_payload = [encode(header), encode(payload.to_json)].join('.')
    digest = Digest::SHA2.hexdigest header_payload
    signature = encode sign(digest)
    [header_payload, signature].join('.')
  end

  # https://tools.ietf.org/html/rfc7515#section-2
  # See Base64url Encoding
  def encode(data)
    Base64.urlsafe_encode64(data.to_s, padding: false)
  end

  def decode(data)
    Base64.urlsafe_decode64(data)
  end
end
