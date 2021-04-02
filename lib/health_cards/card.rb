module HealthCards

  # attr_acessor 

  # Handle JWS with non-JSON Payloads
  class Card

    def initialize(key, payload)
      @key = key
      @payload = payload
    end

    def jws_signature
      signature = @key.sign(jws_payload)
      encode(signature)
    end

    def jose_header
      encode(
        JSON.generate({
                        zip: "DEF",
                        alg: "ES256",
                        kid: @key.thumbprint
                      }
        )
      )
    end

    def jws_payload
      encode(@payload)
    end

    def encode(data)
      Base64.urlsafe_encode64(data, padding: false).gsub("\n", "")
    end

    def decode(data)
      Base64.urlsafe_decode64(data)
    end

    def jws
      [jose_header, jws_payload, jws_signature].join('.')
    end

    def self.verify(jws, key)
      _, payload_to_verify, signature_to_verify = jws.split('.')
      verified = key.verify(payload_to_verify, signature_to_verify)
      [verified, decode(payload_to_verify)]
    end


  end
end