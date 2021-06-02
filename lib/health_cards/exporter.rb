# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Exporter
    class << self
      # Export JWS for file download
      # @param [Array<JWS, String>] An array of JWS objects to be exported
      # @return [String] JSON string containing file download contents
      def download(jws)
        { verifiableCredential: jws.map(&:to_s) }.to_json
      end

      # Export JWS for $issue-health-card endpoint
      # @param [Array<JWS>, String] An array of JWS objects to be exported
      # @return [String] JSON string containing a FHIR Parameters resource
      def issue(jws)
        params = jws.map { |j| FHIR::Parameters::Parameter.new(name: 'verifiableCredential', valueString: j) }
        FHIR::Parameters.new(parameter: params).to_json
      end

      def qr_codes(jws)
        QRCodes.new(jws: jws)
      end
    end
  end
end
