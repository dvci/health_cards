# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Exporter
    extend Chunking

    # Export JWS for file download
    # @param [Array<JWS, String>] An array of JWS objects to be exported
    # @return [String] JSON string containing file download contents
    def self.download(jws)
      { verifiableCredential: jws.map(&:to_s) }.to_json
    end

    # Export JWS for $issue-health-card endpoint
    # @param [Array<WJS, String] An array of JWS objects to be exported
    # @return [String] JSON string containing a FHIR Parameters resource
    def self.issue(jws)
      params = jws.map { |j| FHIR::Parameters::Parameter.new(name: 'verifiableCredential', valueString: j) }
      FHIR::Parameters.new(parameter: params).to_json
    end
  end
end
