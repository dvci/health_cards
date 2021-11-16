# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Importer
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
      qr_codes = QRCodes.new(qr_contents)
      verify_jws qr_codes.to_jws
    end

    # Verify JWS signature
    # @param [String] JWS string
    # @return [Hash] Hash containing the JWS payload and verification contents
    private_class_method def self.verify_jws(jws_string)
      jws = JWS.from_jws jws_string
      result = { payload: Payload.decompress_payload(jws.payload) }
      begin
        result[:verified] = Verifier.verify jws
        result[:error_message] = 'Signature Invalid' if result[:verified] == false
      rescue MissingPublicKeyError, UnresolvableKeySetError => e
        result[:verified] = false
        result[:error_message] = e.message
      end

      result
    end
  end
end
