module HealthCards
  module Exporter
    extend Chunking

    def self.download(jws)
      { verifiableCredential: jws.map(&:to_s) }.to_json
    end

    def self.issue(jws)
      params = jws.map { |j| FHIR::Parameters::Parameter.new(name: 'verifiableCredential', valueString: j) }
      FHIR::Parameters.new(parameter: params).to_json
    end

  end
end