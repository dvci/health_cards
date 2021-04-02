module HealthCards

  # Handle JWS with non-JSON Payloads
  class Card

    attr_reader :header, :payload, :signature

    class << self

      def from_jws(string)
        header, payload_to_verify, signature_to_verify = string.split('.').map { |part| Card::decode(part) }
        @header = JSON.parse(header)
        @payload = payload_to_verify
        @signature = Key.load_string(signature_to_verify)
      end

      def encode(data)
        Base64.urlsafe_encode64(data, padding: false).gsub("\n", "")
      end

      def decode(data)
        Base64.urlsafe_decode64(data)
      end

      def verify(_jws, key)
        card = Card.from_jws(_jws)
        verified = key.verify(payload_to_verify, signature_to_verify)
        [verified, decode(payload_to_verify)]
      end

    end

    def initialize(key, payload)
      @key = key
      @payload = payload
      @header = JSON.generate({
        zip: "DEF",
        alg: "ES256",
        kid: @key.thumbprint
      })

      @signature = @key.sign(encoded_payload)
    end

    def jws
      [header, payload, signature].map { |part| Card::encode(part) }.join('.')
    end

    def encoded_payload
      Card::encode(payload)
    end

    def verify
      @key.verify(encoded_payload, signature)
    end

  end
end