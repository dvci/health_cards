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

<<<<<<< HEAD
=======
    def jwt; end

    def strip_fhir_bundle
      stripped_bundle = @fhir_bundle.dup
      if stripped_bundle.key?('entry') && stripped_bundle['entry'].length.positive?
        entries = stripped_bundle['entry']
        entries, @url_map = redefine_uris(entries)
        update_elements(entries)
      end
      stripped_bundle
    end

    def minify_payload
      JSON.minify(credential.to_json)
    end

    # According to  https://gist.github.com/alazarchuk/8223772181741c4b7a7c
    # Also references https://agileweboperations.com/2008/09/15/how-inflate-and-deflate-data-ruby-and-php/
    def compress_credential
      deflated = Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(minify_payload.to_s, Zlib::FINISH)
      Base64.encode64(deflated)
    end

>>>>>>> f07d4792268d77b3e567cf438b486b095f5e9d06
    private

    def credential_subject
      {
        fhirVersion: FHIR_VERSION,
        fhirBundle: strip_fhir_bundle
      }.tap { |subject| subject[:id] = subject_id if subject_id }
    end

    # Helper methods for strip_fhir_bundle

    def redefine_uris(entries)
      url_map = {}
      resource_count = 0
      entries.each do |entry|
        old_url = entry['fullUrl']
        new_url = "resource:#{resource_count}"
        url_map[old_url] = new_url
        entry['fullUrl'] = new_url
        resource_count += 1
      end
      [entries, url_map]
    end

    def update_elements(entries)
      entries.each do |entry|
        resource = entry['resource']
        resource.delete('id')
        resource.delete('meta')
        resource.delete('text')
        update_nested_elements(resource)
      end
    end

    def update_nested_elements(hash) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      hash.each do |k, v|
        if v.is_a?(Hash) && (k.include?('CodeableConcept') || v.key?('coding'))
          v.delete('text')
        elsif k == 'coding'
          v.each do |coding|
            coding.delete('display')
          end
        elsif k == 'reference' && v.is_a?(String)
          v.replace @url_map[v] if @url_map.key?(v)
        end

        case v
        when Hash
          update_nested_elements(v)
        when Array
          v.flatten.each { |x| update_nested_elements(x) if x.is_a?(Hash) }
        end
      end
      hash
    end
  end
end
