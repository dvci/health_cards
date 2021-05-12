# frozen_string_literal: true

module HealthCards
  # A key used for verifying JWS
  class PublicKey < Key
    def self.from_json(json)
      # TODO
    end

    def raw_to_asn1(signature, public_key)
      byte_size = (public_key.group.degree + 7) / 8
      r = signature[0..(byte_size - 1)]
      s = signature[byte_size..-1]
      OpenSSL::ASN1::Sequence.new([r, s].map { |int| OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(int, 2)) }).to_der
    end

    def verify(payload, signature)
      @key.dsa_verify_asn1(payload, signature)
      # Alternative:
      # @key.verify(OpenSSL::Digest::SHA256.new, signature, payload)
    end
  end
end
