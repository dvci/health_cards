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
      # @param jws [String, HealthCards::JWS] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        unless jws.is_a?(HealthCards::JWS) || jws.is_a?(String)
          raise ArgumentError,
                'Expected either a HealthCards::JWS or String'
        end

        header, payload, signature = jws.to_s.split('.').map { |entry| decode(entry) }
        header = JSON.parse(header)
        jws = JWS.new(header: header, payload: payload, signature: signature,
                public_key: public_key, key: key)
        puts jws.signature
        jws
      end
    end

    attr_reader :key, :public_key, :payload
    attr_accessor :header

    # Create a new JWS

    def initialize(header: nil, payload: nil, signature: nil, key: nil, public_key: nil)
      # Not using accessors because they reset the signature which requires both a key and a payload
      @header = header
      @payload = payload
      @signature = signature
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
      puts 'we hit'
      raise MissingPublicKey unless public_key
      ppayload = "#{JWS.encode(@header.to_json)}.#{encoded_payload}"
      puts "My Payload: #{JWS.encode(@header.to_json)}.#{encoded_payload}"
      puts "signature: #{signature}"
      puts signature
      public_key.verify(OpenSSL::Digest.new('sha256').digest(ppayload), raw_to_asn1(signature, public_key))
      # Alternative:
      # public_key.verify(ppayload, raw_to_asn1(signature, public_key))
    end

    private

    def raw_to_asn1(signature, private_key)
      byte_size = (private_key.group.degree + 7) / 8
      sig_bytes = signature[0..(byte_size - 1)]
      sig_char = signature[byte_size..-1] || ''
      OpenSSL::ASN1::Sequence.new([sig_bytes, sig_char].map { |int| OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(int, 2)) }).to_der
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
