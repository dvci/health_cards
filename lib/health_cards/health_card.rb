# frozen_string_literal: true

module HealthCards
  # a HealthCard which can be encoded as a JWS
  class HealthCard

    class << self

      # Encodes the provided data using url safe base64 without padding
      # @param data [String] the data to be encoded
      # @return [String] the encoded data
      def encode(data)
        # Base64.urlsafe_encode64(data, padding: false).gsub("\n", '')
      end

      # Decodes the provided data using url safe base 64
      # @param data [String] the data to be decoded
      # @return [String] the decoded data
      def decode(data)
        # Base64.urlsafe_decode64(data)
      end

      # Creates a Card from a JWS
      # @param jws [String] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        jws = JWS.from_jws(jws, public_key: public_key, key: key)

        vc = VerifiableCredential.decompress_credential(jws.payload)
        HealthCard.new(verifiable_credential: vc, public_key: public_key, key: key, signature: jws.signature)
      end
    end

    attr_reader :key, :public_key, :verifiable_credential
    attr_accessor :resolve_keys

    # Create a HealthCard
    #
    # @param payload [HealthCards::VerifiableCredential, String] the FHIR bundle used as the Health Card payload
    def initialize(verifiable_credential: nil, key: nil, public_key: nil, signature: nil)
      self.verifiable_credential = verifiable_credential
      self.key = key
      self.public_key = public_key || key&.public_key
      @signature = signature
    end

    # Set the private key used for signing issued health cards
    #
    # @param public_key [HealthCards::PublicKey, nil] the private key used for signing issued health cards
    def public_key=(public_key)
      raise HealthCards::MissingPublicKey unless public_key.is_a?(PublicKey) || public_key.nil?
      reset_header
      @public_key = public_key
    end

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    def key=(key)
      raise HealthCards::MissingPrivateKey unless key.is_a?(PrivateKey) || key.nil?

      @key = key

      @public_key = key&.public_key
    end

    # The signature component of the card
    #
    # @return [String] the unencoded signature
    # delegate :signature, to: :jws

    # Verify the digital signature on the card
    #
    # @return [Boolean]
    delegate :verify, to: :to_jws

    # The payload component of the card
    #
    # @return [String] the payload
    # delegate :payload, to: :jws

    # The private key
    #
    # @return [HealthCards::Key] the private key
    # delegate :key, to: :jws
    # delegate :public_key, to: :jws

    # delegate :thumbprint, to: :jws

    # Set the HealthCard payload
    #
    # @param payload [HealthCards::VerifiableCredential, String] the FHIR bundle used as the Health Card payload
    def verifiable_credential=(new_payload)
      raise InvalidPayloadException unless new_payload.nil? || new_payload.is_a?(HealthCards::VerifiableCredential)
      @verifiable_credential = new_payload
    end

    # Encode the HealthCard as a JWS
    #
    # @return [String] the JWS string
    # def to_jws
    #   jws.to_s
    # end

    # Save the HealthCard as a file
    #
    # @param file_name [String] the name of the file
    def save_to_file(file_name)
      file_data = {
        verifiableCredential: [to_jws.to_s]
      }

      File.open(file_name, 'w') do |file|
        file.write(file_data.to_json)
      end
    end

    def to_json(*_args)
      { verifiableCredential: [jws.to_s] }.to_json
    end

    # Whether the instance is configured to resolve public keys
    #
    # @return [Boolean]
    def resolves_keys?
      resolve_keys
    end

    # The header component of the card
    #
    # @return [Hash] the header
    def header
      return @header if @header

      raise MissingPublicKey unless public_key
      # Use strings as keys here for consistency with parsed JSON
      @header ||= { 'zip' => 'DEF', 'alg' => 'ES256', 'kid' => public_key.thumbprint }
    end

    def chunks
      HealthCards::Chunking.generate_qr_chunks payload.to_s
    end

    def to_jws
      if @signature
        JWS.new(payload: verifiable_credential.compress_credential, header: header, key: key, public_key: public_key, signature: @signature)
      elsif key
        JWS.new(payload: verifiable_credential.compress_credential, header: header, key: key, public_key: public_key)
      else
        raise MissingPrivateKey.new
      end
    end

    private



    # Check if argument is a FHIR Bundle
    #
    # @param bundle [Object] the suspected FHIR Bundle
    # @return [Boolean]
    # def fhir_bundle?(bundle)
    #   bundle_obj = bundle.is_a?(String) ? FHIR.from_contents(bundle) : bundle
    #   bundle_obj.is_a? FHIR::Bundle
    # rescue JSON::ParserError
    #   false
    # end

    # Resets the header
    #
    # This method is primarily used when an attribute that affects
    # the header is changed (e.g. the public key changes)
    def reset_header
      @header = nil
    end

    # Exception thrown when an invalid payload is provided
    class InvalidPayloadException < ArgumentError
      def initialize(msg = 'Payload must be a HealthCards::VerifiableCredential')
        super(msg)
      end
    end
  end
end
