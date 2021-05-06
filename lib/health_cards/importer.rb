# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Importer
    extend Chunking

    # Import JWS from file upload
    # @param  [String] JSON string containing file upload contents
    # @return [Array<JWS>] An array of JWS objects
    def self.upload(jws_string)
      vc = JSON.parse(jws_string)
      vc_jws = vc['verifiableCredential']
      vc_jws.map do |j|
        jws = JWS.from_jws(j)
        HealthCard.decompress_payload(jws.payload)
      end
    end

    def self.scan(qr_contents)
      contents = JSON.parse(qr_contents)
      get_payload_from_qr contents
    end
  end
end
