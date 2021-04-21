# frozen_string_literal: true

module HealthCards
  # a HealthCard which can be encoded as a JWS
  class HealthCard
    class << self
      # Creates a Card from a JWS
      # @param jws [String] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        jws = JWS.from_jws(jws, public_key: public_key, key: key)
        vc = VerifiableCredential.decompress_credential(jws.payload)
        HealthCard.new(verifiable_credential: vc, jws: jws)
      end
    end

    attr_reader :verifiable_credential, :jws

    # Create a HealthCard
    #
    # @param payload [HealthCards::VerifiableCredential, String] the FHIR bundle used as the Health Card payload
    def initialize(verifiable_credential: nil, jws: nil)
      self.verifiable_credential = verifiable_credential
      @jws = jws
    end

    # Set the HealthCard payload
    #
    # @param payload [HealthCards::VerifiableCredential, String] the FHIR bundle used as the Health Card payload
    def verifiable_credential=(new_payload)
      raise InvalidPayloadException unless new_payload.nil? || new_payload.is_a?(HealthCards::VerifiableCredential)

      @jws.payload = new_payload&.compress_credential if @jws
      @verifiable_credential = new_payload
    end

    # Save the HealthCard as a file
    #
    # @param file_name [String] the name of the file
    def save_to_file(file_name)
      File.open(file_name, 'w') do |file|
        file.write(to_json)
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

    # Exception thrown when an invalid payload is provided
    class InvalidPayloadException < ArgumentError
      def initialize(msg = 'Payload must be a HealthCards::VerifiableCredential')
        super(msg)
      end
    end
  end
end
