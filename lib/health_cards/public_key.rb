# frozen_string_literal: true

module HealthCards
  # A key used for verifying JWS
  class PublicKey < Key
    def self.from_json(json)
      # TODO
    end

    def verify(payload, signature)
      @key.verify(OpenSSL::Digest.new('SHA256'), raw_to_asn1(signature, self), payload)
    end

    private

    def raw_to_asn1(signature, key)
      byte_size = (key.group.degree + 7) / 8
      sig_bytes = signature[0..(byte_size - 1)]
      sig_char = signature[byte_size..] || ''
      OpenSSL::ASN1::Sequence.new([sig_bytes, sig_char].map do |int|
        OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(int, 2))
      end).to_der
    end
  end
end
