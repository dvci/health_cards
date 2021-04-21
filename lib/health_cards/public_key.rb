# frozen_string_literal: true

module HealthCards
  # A key used for verifying JWS
  class PublicKey < Key
    def self.from_json(json)
      # TODO
    end

    def verify(payload, signature)
      @key.dsa_verify_asn1(payload, signature)
    end
  end
end
