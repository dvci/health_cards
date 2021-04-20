# frozen_string_literal: true

module HealthCards
  # Create JWS from a payload
  class JWS

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
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        header, payload, signature = jws.split('.').map { |entry| decode(entry) }
        header = JSON.parse(header)
        JWS.new(header: header, payload: payload, signature: signature,
                       public_key: public_key, key: key)
      end
    end

    attr_reader :key, :public_key
    attr_writer :signature
    attr_accessor :header, :payload

    # Create a new JWS

    def initialize(header: nil, payload: nil, signature: nil, public_key: nil, key: nil)
      self.key = key
      self.public_key = public_key || key&.public_key
      self.payload = payload
      self.header = header
      self.signature = signature
    end

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    def key=(key)
      raise HealthCards::MissingPrivateKey unless key.is_a?(PrivateKey) || key.nil?

      reset_signature
      @key = key
    end

    # Set the private key used for signing issued health cards
    #
    # @param public_key [HealthCards::PublicKey, nil] the private key used for signing issued health cards
    def public_key=(public_key)
      raise HealthCards::MissingPublicKey unless public_key.is_a?(PublicKey) || public_key.nil?

      @public_key = public_key
    end

    # The signature component of the card
    #
    # @return [String] the unencoded signature
    def signature
      return @signature if @signature

      raise MissingPrivateKey unless key

      @signature ||= key.sign(encoded_payload)
    end

    # Export the card to a JWS String
    # @return [String] the JWS
    def to_s
      [JSON.generate(header), payload, signature].map { |entry| JWS.encode(entry) }.join('.')
    end

    # Verify the digital signature on the jws
    #
    # @return [Boolean]
    def verify
      raise MissingPublicKey unless public_key

      public_key.verify(encoded_payload, signature)
    end

    private

    def encoded_payload
      JWS.encode(payload)
    end

    # Resets the signature
    #
    # This method is primarily used when an attribute that affects
    # the signature is changed (e.g. the private key changes, the payload changes)
    def reset_signature
      @signature = nil
    end
  end
end
