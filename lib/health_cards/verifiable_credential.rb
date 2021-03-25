# frozen_string_literal: true

require 'date'

module HealthCards
  # Generates a Verifiable Credential which can be issued
  # https://www.w3.org/TR/vc-data-model/
  class VerifiableCredential
    VC_CONTEXT = ['https://www.w3.org/2018/credentials/v1'].freeze

    VC_TYPE = [
      'VerifiableCredential',
      'https://healthwallet.cards#health-card',
      'https://healthwallet.cards#presentation-context-online',
      'https://healthwallet.cards#covid19'
    ].freeze

    FHIR_VERSION = '4.0.1'

    ENCRYPTION_KEY_TYPE = 'JsonWebKey2020'

    VERIFICATION_KEY_TYPE = 'EcdsaSecp256k1VerificationKey2019'

    # include DigitalSignature

    attr_reader :fhir_bundle, :subject_id

    def initialize(fhir_bundle, subject_id = nil)
      @fhir_bundle = fhir_bundle
      @subject_id = subject_id
    end

    def credential
      {
        '@context': VC_CONTEXT,
        type: VC_TYPE,
        credentialSubject: credential_subject # ,
        # proof: proof(credential_subject)
      }
    end

    private

    def credential_subject
      {
        fhirVersion: FHIR_VERSION,
        fhirBundle: fhir_bundle
      }.tap { |subject| subject[:id] = subject_id if subject_id }
    end
  end
end
