# frozen_string_literal: true

module HealthCards
  # Construct JWS Health Cards.
  #
  # Provides methods for generating the JWS representation of a Health Card.
  class Card
    attr_writer :signature, :header
    attr_reader :private_key, :public_key
    attr_accessor :payload

    class << self
      # Encodes the provided data using url safe base64 without padding
      # @param data [String] the data to be encoded
      # @return [String] the encoded data
      def encode(data)
        Base64.urlsafe_encode64(data, padding: false).gsub("\n", '')
      end

      # Decodes the provided data using url safe base 64
      # @param data [String] the data to be decoded
      # @return [String] the decoded data
      def decode(data)
        Base64.urlsafe_decode64(data)
      end

      # Creates a Card from a JWS
      # @param jws [String] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param private_key [HealthCards::PublicKey] the private key associated with the JWS
      # @return [HealthCards::Card]
      def from_jws(jws, public_key: nil, private_key: nil)
        header, payload, signature = jws.split('.').map { |entry| decode(entry) }
        Card.new(header: header, payload: payload, signature: signature,
                 public_key: public_key, private_key: private_key)
      end

      # Verify the JWS using the public key
      # @param jws [String] the JWS
      # @param key [HealthCards::PublicKey] the public key
      # @return [Boolean]
      def verify(jws, key)
        Card.from_jws(jws, public_key: key).verify
      end
    end

    # Create a Card
    def initialize(payload:, private_key: nil, public_key: nil, header: nil, signature: nil)
      @payload = payload
      @private_key = private_key

      # Use the given public key, otherwise get the public key from the private key
      @public_key = public_key || private_key&.public_key
      @signature = signature
      @header = header
    end

    # Export the card to a JWS
    # @return [String] the JWS
    def to_jws
      [header, payload, signature].map { |entry| Card.encode(entry) }.join('.')
    end

    def private_key=(new_private_key)
      reset_signature
      @private_key = new_private_key
    end

    def public_key=(new_public_key)
      reset_header
      @public_key = new_public_key
    end

    # The header component of the card
    # @return [String] the header
    def header
      return @header if @header

      raise MissingPublicKey unless public_key

      @header ||= JSON.generate({
                                  zip: 'DEF',
                                  alg: 'ES256',
                                  kid: @public_key.thumbprint
                                })
    end

    # The signature component of the card
    # @return [String] the unencoded signature
    def signature
      return @signature if @signature

      raise MissingPrivateKey unless private_key

      @signature ||= private_key.sign(encoded_payload)
    end

    # Verify the digital signature on the card
    # @return [Boolean]
    def verify
      raise MissingPublicKey unless public_key

      @public_key.verify(encoded_payload, signature)
    end

    private

    def reset_signature
      @signature = nil
    end

    def reset_header
      @header = nil
    end

    def encoded_payload
      Card.encode(payload)
    end

    # Thrown when attempting to sign a card without providing a private key
    class MissingPrivateKey < StandardError
      def initialize(msg = nil)
        msg ||= 'Missing private key'
        super(msg)
      end
    end

    # Thrown when attempting to verify a card without providing a public key
    class MissingPublicKey < StandardError
      def initialize(msg = nil)
        msg ||= 'Missing private key'
        super(msg)
      end
    end
  end
end
