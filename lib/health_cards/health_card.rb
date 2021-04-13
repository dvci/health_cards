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
        # header, payload, signature = jws.split('.').map { |entry| decode(entry) }
        # header = JSON.parse(header)
        # HealthCard.new(header: header, payload: payload, signature: signature,
        #                public_key: public_key, key: key)
      end
    end

    attr_reader :key, :public_key
    attr_writer :signature, :header
    attr_accessor :resolve_keys

    # Create a HealthCard
    #
    # @param payload [FHIR::Bundle, String] the FHIR bundle used as the Health Card payload
    def initialize(payload: nil, key: nil, public_key: nil, header: nil, signature: nil)
      self.key = key
      self.public_key = public_key
      self.payload = payload
      self.header = header
      self.signature = signature
    end

    # The signature component of the card
    #
    # @return [String] the unencoded signature
    delegate :signature, to: :jws

    # Set the private key used for signing issued health cards
    #
    # @param key [HealthCards::PrivateKey, nil] the private key used for signing issued health cards
    delegate :key=, to: :jws

    # Verify the digital signature on the card
    #
    # @return [Boolean]
    delegate :verify, to: :jws

    # Set the HealthCard payload
    #
    # @param payload [FHIR::Bundle, String] the FHIR bundle used as the Health Card payload
    def payload=(payload)
      raise InvalidPayloadException unless fhir_bundle? payload

      jws.payload = payload
    end

    def payload
      @payload
    end

    # Set the private key used for signing issued health cards
    #
    # @param public_key [HealthCards::PublicKey, nil] the private key used for signing issued health cards
    def public_key=(public_key)
      raise HealthCards::MissingPublicKey unless public_key.is_a?(PublicKey) || public_key.nil?

      reset_header
      @public_key = public_key
    end

    # Encode the HealthCard as a JWS
    #
    # @return [String] the JWS string
    def to_jws
      jws.to_s
    end

    # Save the HealthCard as a file
    #
    # @param file_name [String] the name of the file
    def save_to_file(file_name)
      file_data = {
        verifiableCredential: [self.to_jws]
      }

      File.open(file_name, 'w') do |file|
        file.write(file_data.to_json)
      end
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

      @header ||= { zip: 'DEF', alg: 'ES256', kid: @public_key.thumbprint }
    end

    private

    def jws
      @jws ||= JWS.new(payload: payload, header: header, signature: signature, key: key, public_key: public_key)
    end

    # Check if argument is a FHIR Bundle
    #
    # @param bundle [Object] the suspected FHIR Bundle
    # @return [Boolean]
    def fhir_bundle?(bundle)
      bundle = FHIR.from_contents(bundle) if bundle.is_a? String
      bundle.is_a? FHIR::Bundle
    end

    # Resets the signature
    #
    # This method is primarily used when an attribute that affects
    # the signature is changed (e.g. the private key changes, the payload changes)
    def reset_signature
      @signature = nil
    end

    # Resets the header
    #
    # This method is primarily used when an attribute that affects
    # the header is changed (e.g. the public key changes)
    def reset_header
      @header = nil
    end

    # Exception thrown when an invalid payload is provided
    class InvalidPayloadException < ArgumentError
      def initialize(msg = 'Payload must be a FHIR Bundle')
        super(msg)
      end
    end
  end
end