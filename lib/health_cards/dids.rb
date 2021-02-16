# frozen_string_literal: true

require 'multihashes'
require 'digest'
require 'base64'

# Methods that generate and resolve DIDs
module Dids
  # https://tools.ietf.org/html/rfc7515#section-2
  # See Base64url Encoding
  def encode(data)
    Base64.urlsafe_encode64(data.to_s, padding: false)
  end

  # https://identity.foundation/sidetree/spec/#hashing-process
  def sidetree_hash(data)
    digest = Digest::SHA256.digest data
    Multihashes.encode(digest, 'sha2-256')
  end

  # https://identity.foundation/sidetree/spec/#public-key-commitment-scheme
  # canonicalize jwk encoded public key
  # hash cononicalized public key
  # hash resulting hash value again
  def reveal_commitment(jwk)
    jwk_canonicalized = jwk.to_json_c14n
    first_hash = encode sidetree_hash(jwk_canonicalized)
    encode sidetree_hash(first_hash)
  end

  # https://identity.foundation/sidetree/spec/#create
  def generate_did(encryption_public_jwk, signing_public_jwk, update_public_jwk, recovery_public_jwk)
    recovery_commitment = reveal_commitment(recovery_public_jwk)
    update_commitment = reveal_commitment(update_public_jwk)
    patches = [
      {
        action: 'add-public-keys',
        publicKeys: [
          {
            id: 'signing-key-1',
            purpose: %w[general auth],
            type: 'EcdsaSecp256k1VerificationKey2019',
            jwk: signing_public_jwk
          },
          {
            id: 'encryption-key-1',
            purpose: %w[general auth],
            type: 'JsonWebKey2020',
            jwk: encryption_public_jwk
          }
        ]
      }
    ]
    delta = {
      updateCommitment: update_commitment,
      patches: patches
    }
    delta_cononical = delta.to_json_c14n
    suffix_data = {
      deltaHash: encode(sidetree_hash(delta_cononical)),
      recoveryCommitment: recovery_commitment
    }
    suffix_data_canonical = suffix_data.to_json_c14n
    suffix = encode sidetree_hash(suffix_data_canonical)
    long_payload = {
      delta: delta,
      suffixData: suffix_data
    }
    long_payload_encoded = encode long_payload.to_json_c14n
    {
      didShort: "did:ion:#{suffix}",
      didLong: "did:ion:#{suffix}:#{long_payload_encoded}"
    }
  end

  def resolve_did_long(did_long)
    # did format: did:ion:<did-suffix>:<long-form-encoded-data>
    encoded_payload = did_long.split(':').last
    JSON.parse(Base64.urlsafe_decode64(encoded_payload))
  end
end
