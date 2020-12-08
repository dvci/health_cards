# frozen_string_literal: true

require 'date'

module HealthCards
  # Generates a Verifiable Credential which can be issued
  class VerifiableCredential
    VC_CONTEXT = ['https://www.w3.org/2018/credentials/v1'].freeze

    VC_TYPE = [
      'VerifiableCredential',
      'https://healthwallet.cards#health-card',
      'https://healthwallet.cards#presentation-context-online',
      'https://healthwallet.cards#covid19'
    ].freeze

    FHIR_VERSION = '4.0.1'

    attr_reader :fhir_bundle, :subject_id

    def initialize(fhir_bundle, subject_id = nil)
      @fhir_bundle = fhir_bundle
      @subject_id = subject_id
    end

    def credential
      {
        '@context': VC_CONTEXT,
        type: VC_TYPE,
        issuer: '<<did:ion identifier for lab>>',
        issuanceDate: DateTime.now.to_s,
        credentialSubject: credential_subject
      }
    end

    def jwt; end

    private

    def credential_subject
      {
        fhirVersion: FHIR_VERSION,
        fhirBundle: fhir_bundle
      }.tap { |subject| subject[:id] = subject_id if subject_id }
    end
  end
end
