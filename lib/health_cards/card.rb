# frozen_string_literal: true

module HealthCards
  # Handle JWS with non-JSON Payloads
  class Card
    attr_writer :signature
    attr_reader :private_key
    attr_accessor :public_key, :payload, :header

    class << self
      def encode(data)
        Base64.urlsafe_encode64(data, padding: false).gsub("\n", '')
      end

      def decode(data)
        Base64.urlsafe_decode64(data)
      end

      def from_jws(jws, public_key: nil, private_key: nil)
        header, payload, signature = jws.split('.').map { |entry| decode(entry)}
        Card.new(header: header, payload: payload, signature: signature,
                 public_key: public_key, private_key: private_key)
      end

      def verify(jws, key)
        Card.from_jws(jws, public_key: key).verify
      end
    end

    def initialize(payload:, private_key: nil, public_key: nil, header: nil, signature: nil)
      @payload = payload
      @private_key = private_key
      @public_key = public_key
      @signature = signature
      @header = header || JSON.generate({
                                          zip: 'DEF',
                                          alg: 'ES256',
                                          kid: @public_key.thumbprint
                                        })

    end

    def to_jws
      [header, payload, signature].map{|entry| Card.encode(entry)}.join('.')
    end

    def encoded_payload
      Card.encode(payload)
    end

    def private_key=(new_private_key)
      reset_signature
      @private_key = new_private_key
    end

    def signature
      return @signature if @signature

      raise MissingPrivateKey.new unless private_key

      @signature ||= private_key.sign(encoded_payload)
    end

    def verify
      raise MissingPublicKey.new unless public_key

      @public_key.verify(encoded_payload, signature)
    end

    private

    def reset_signature
      @signature = nil
    end

    class MissingPrivateKey < StandardError
      def initialize(msg = nil)
        msg ||= "Missing private key"
        super(msg)
      end
    end

    class MissingPublicKey < StandardError
      def initialize(msg = nil)
        msg ||= "Missing private key"
        super(msg)
      end
    end
  end
end
