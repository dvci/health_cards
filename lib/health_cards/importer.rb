# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Importer
    extend Chunking

    # Import JWS from file upload
    # @param  [String] JSON string containing file upload contents
    # @return [Array<Hash>] An array of Hashes containing JWS payload and verification contents
    def self.upload(jws_string)
      vc = JSON.parse(jws_string)
      vc_jws = vc['verifiableCredential']
      vc_jws.map do |j|
        verify_jws j
      end
    end

    # Scan QR code
    # @param [Array<String>] Array containing numeric QR chunks
    # @return [Hash] Hash containing the JWS payload and verification contents
    def self.scan(qr_contents)
      jws_string = qr_chunks_to_jws qr_contents
      verify_jws jws_string
    end

    # Verify JWS signature
    # @param [String] JWS string
    # @return [Hash] Hash containing the JWS payload and verification contents
    private_class_method def self.verify_jws(jws_string)
      jws = JWS.from_jws jws_string
      result = { payload: HealthCard.decompress_payload(jws.payload) }
      begin
        result[:verified] = Verifier.verify jws
        result[:error_message] = 'Signature Invalid' if result[:verified] == false
      rescue MissingPublicKey
        result[:verified] = false
        result[:error_message] = 'Cannot find public key'
      end
      result
    end
  end
end
