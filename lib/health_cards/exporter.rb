# frozen_string_literal: true

module HealthCards
  # Converts a JWS to formats needed by endpoints (e.g. $issue-health-card, download and qr code)
  module Exporter
    class << self
      # Export JWS for file download
      # @param [Array<JWS, String>] An array of JWS objects to be exported
      # @return [String] JSON string containing file download contents
      def file_download(jws)
        { verifiableCredential: jws.map(&:to_s) }.to_json
      end

      # Export JWS for $issue-health-card endpoint
      # @param [FHIR::Parameters] A FHIR::Parameters object
      # @yields [types] An array of strings representing the types in the FHIR::Parameters.
      # Expects block to return JWS instances for those types
      # @return [String] JSON string containing a FHIR Parameters resource
      def issue(fhir_params)
        *jws = yield extract_types!(fhir_params)

        params = jws.compact.map { |j| FHIR::Parameters::Parameter.new(name: 'verifiableCredential', valueString: j) }

        FHIR::Parameters.new(parameter: params).to_json
      end

      def qr_codes(jws)
        QRCodes.from_jws(jws)
      end

      private

      def extract_types!(fhir_params)
        if fhir_params.nil?
          code = 'structure'
          err_msg = 'No Parameters found'
        elsif !fhir_params.valid?
          code = 'invalid'
          err_msg = fhir_params.validate.to_s
        else
          types = fhir_params.parameter.map(&:valueUri).compact
          if types.empty?
            code = 'required'
            err_msg = 'Invalid Parameter: Expected valueUri'
          end
        end

        raise InvalidParametersError.new(code: code, message: err_msg) if code

        types
      end
    end
  end
end
