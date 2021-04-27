# frozen_string_literal: true

module HealthCards
  # A HealthCard which can be encoded as a JWS
  class HealthCard
    VC_TYPE = [
      'https://healthwallet.cards#health-card'
    ].freeze

    attr_reader :issuer, :nbf, :bundle

    class << self
      # Creates a Card from a JWS
      # @param jws [String] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        jws = JWS.from_jws(jws, public_key: public_key, key: key)
        from_payload(jws.payload)
      end

      def from_payload(payload)
        inf = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(payload)
        json = JSON.parse(inf)

        bundle_hash = json.dig('vc', 'credentialSubject', 'fhirBundle')

        raise HealthCards::InvalidCredentialException unless bundle_hash

        bundle = FHIR::Bundle.new(bundle_hash)
        new(issuer: json['iss'], bundle: bundle)
      end

      def compress_payload(payload)
        Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(payload.to_s, Zlib::FINISH)
      end

      def allow(klass, attributes)
        @allowable ||= {}
        resource_type = klass.name.split('::').last
        @allowable[resource_type] = attributes
      end

      def allowable
        @allowable ||= {}
      end

      def fhir_version(ver = nil)
        @fhir_version ||= ver unless ver.nil?
        @fhir_version
      end

      def additional_types(*types)
        @types ||= VC_TYPE
        @types += types
      end

      def types
        @types ||= VC_TYPE
      end
    end

    # Create a HealthCard
    #
    # @param verifiable_credential [HealthCards::VerifiableCredential] VerifiableCredential containing a fhir bundle
    # @param jws [HealthCards::JWS] JWS which should have a payload generated from the verifiable_credential
    def initialize(bundle:, issuer: nil)
      raise InvalidPayloadException unless bundle.is_a?(FHIR::Bundle)

      @issuer = issuer
      @bundle = bundle
    end

    def to_hash
      {
        iss: issuer,
        nbf: Time.now.to_i,
        vc: {
          type: self.class.types,
          credentialSubject: {
            fhirVersion: self.class.fhir_version,
            fhirBundle: strip_fhir_bundle
          }
        }

      }
    end

    def to_s
      HealthCard.compress_payload(minify_payload)
    end

    def to_json(*args)
      to_hash.to_json(*args)
    end

    # Whether the instance is configured to resolve public keys
    #
    # @return [Boolean]
    def resolves_keys?
      resolve_keys
    end

    def chunks
      HealthCards::Chunking.generate_qr_chunks to_s
    end

    def minify_payload
      JSON.minify(to_hash.to_json)
    end

    def strip_fhir_bundle
      stripped_bundle = @bundle.to_hash
      if stripped_bundle.key?('entry') && !stripped_bundle['entry'].empty?
        entries = stripped_bundle['entry']
        entries, @url_map = redefine_uris(entries)
        update_elements(entries)
      end
      stripped_bundle
    end

    private

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
        resource.delete('text')
        if resource.dig('meta', 'security')
          resource['meta'] = resource['meta'].slice('security')
        else
          resource.delete('meta')
        end
        handle_allowable(resource)
        update_nested_elements(resource)
      end
    end

    def handle_allowable(resource)
      allowable = self.class.allowable[resource['resourceType']]
      return resource unless allowable

      allow = allowable + ['resourceType']
      resource.select! { |att| allow.include?(att) }
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
          hash[k] = @url_map[v] if @url_map.key?(v)
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
