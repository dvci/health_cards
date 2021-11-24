# frozen_string_literal: true

module HealthCards
  # Create JWS from a payload
  class JWS
    class << self
      include Encoding

      # Creates a JWS from a String representation, or returns the HealthCards::JWS object
      # that was passed in
      # @param jws [String, HealthCards::JWS] the JWS string, or a JWS object
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::JWS] A new JWS object, or the JWS object that was passed in
      def from_jws(jws, public_key: nil, key: nil)
        return jws if jws.is_a?(HealthCards::JWS) && public_key.nil? && key.nil?

        unless jws.is_a?(HealthCards::JWS) || jws.is_a?(String)
          raise ArgumentError,
                'Expected either a HealthCards::JWS or String'
        end

        header, payload, signature = jws.to_s.split('.').map { |entry| decode(entry) }
        header = JSON.parse(header)
        JWS.new(header: header, payload: payload, signature: signature,
                public_key: public_key, key: key)
      end
    end

    attr_reader :key, :public_key, :payload
    attr_writer :signature
    attr_accessor :header

    # Create a new JWS

    def initialize(header: nil, payload: nil, signature: nil, key: nil, public_key: nil)
      # Not using accessors because they reset the signature which requires both a key and a payload
      @header = header
      @payload = payload
      @signature = signature if signature
      @key = key
      @public_key = public_key || key&.public_key
    end

    # The kid value from the JWS header, used to identify the key to use to verify
    # @return [String]
    def kid
      header['kid']
    end

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    def key=(key)
      PrivateKey.enforce_valid_key_type!(key, allow_nil: true)

      @key = key

      # If it's a new private key then the public key and signature should be updated
      return if @key.nil?

      reset_signature
      self.public_key = @key.public_key
    end

    # Set the public key used for signing issued health cards
    #
    # @param public_key [HealthCards::PublicKey, nil] the private key used for signing issued health cards
    def public_key=(public_key)
      PublicKey.enforce_valid_key_type!(public_key, allow_nil: true)

      @public_key = public_key
    end

    # Set the JWS payload. Setting a new payload will result in the a new signature
    # @param new_payload [Object]
    def payload=(new_payload)
      @payload = new_payload
      reset_signature
    end

    # The signature component of the card
    #
    # @return [String] the unencoded signature
    def signature
      return @signature if @signature

      raise MissingPrivateKeyError unless key

      @signature ||= key.sign(jws_signing_input)
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
      raise MissingPublicKeyError unless public_key

      public_key.verify(jws_signing_input, signature)
    end

    private

    def jws_signing_input
      "#{JWS.encode(@header.to_json)}.#{encoded_payload}"
    end

    def encoded_payload
      JWS.encode(payload)
    end

    # Resets the signature
    #
    # This method is primarily used when an attribute that affects
    # the signature is changed (e.g. the private key changes, the payload changes)
    def reset_signature
      @signature = nil
      signature if key && payload
    end
  end
end
