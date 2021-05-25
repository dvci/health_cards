# frozen_string_literal: true

require 'json/minify'
require 'zlib'

module HealthCards
  # A HealthCard which implements the credential claims specified by https://smarthealth.cards/
  class HealthCard
    VC_TYPE = [
      'https://smarthealth.cards#health-card'
    ].freeze

    attr_reader :issuer, :nbf, :bundle

    class << self
      # Creates a HealthCard from a JWS
      # @param jws [String] the JWS string
      # @param public_key [HealthCards::PublicKey] the public key associated with the JWS
      # @param key [HealthCards::PrivateKey] the private key associated with the JWS
      # @return [HealthCards::HealthCard]
      def from_jws(jws, public_key: nil, key: nil)
        jws = JWS.from_jws(jws, public_key: public_key, key: key)
        from_payload(jws.payload)
      end

      # Create a HealthCard from a compressed payload
      # @param payload [String]
      # @return [HealthCards::HealthCard]
      def from_payload(payload)
        json = decompress_payload(payload)
        bundle_hash = json.dig('vc', 'credentialSubject', 'fhirBundle')

        raise HealthCards::InvalidCredentialException unless bundle_hash

        bundle = FHIR::Bundle.new(bundle_hash)
        new(issuer: json['iss'], bundle: bundle)
      end

      # Decompress an arbitrary payload, useful for debugging
      # @param payload [String] compressed payload
      # @return [Hash] Hash built from JSON contents of payload
      def decompress_payload(payload)
        inf = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(payload)
        JSON.parse(inf)
      end

      # Compress an arbitrary payload, useful for debugging
      # @param payload [Object] Any object that responds to to_s
      # @return A compressed version of that payload parameter
      def compress_payload(payload)
        Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(payload.to_s, Zlib::FINISH)
      end

      # Define allowed attributes for this HealthCard class
      # @param klass [Class] Scopes the attributes to a spefic class. Must be a subclass of FHIR::Model
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def allow(klass, attributes)
        allowable[klass] = attributes
      end

      # Define disallowed attributes for this HealthCard class
      # @param klass [Class] Scopes the attributes to a spefic class. Must be a subclass of FHIR::Model
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def disallow(klass, attributes)
        disallowable[klass] = attributes
      end

      # Define allowed attributes for this HealthCard class
      # @return [Hash] A hash of FHIR::Model subclasses and attributes that will pass through minimization
      def allowable
        return @allowable if @allowable

        base = superclass == HealthCards::HealthCard ? superclass.allowable : {}
        @allowable = base
      end

      # Define disallowed attributes for this HealthCard class
      # @return [Hash] A hash of FHIR::Model subclasses and attributes that will pass through minimization
      def disallowable
        return @disallowable if @disallowable

        base = superclass == HealthCards::HealthCard ? superclass.disallowable : {}
        @disallowable = base
      end

      # Sets/Gets the fhir version that will be passed through to the credential created by an instnace of
      # this HealthCard (sub)class
      # @param ver [String] FHIR Version supported by this HealthCard (sub)class. Leaving this param out
      # will only return the current value
      # value (used as a getter)
      # @return [String] Current FHIR version supported
      def fhir_version(ver = nil)
        @fhir_version ||= ver unless ver.nil?
        @fhir_version
      end

      # Additional type claims this HealthCard class supports
      # @param types [String, Array] A string or array of string representing the additional type claims or nil
      # if used as a getter
      # @return [Array] the additional types added by this classes
      def additional_types(*add_types)
        types.concat(add_types) unless add_types.nil?
        types - VC_TYPE
      end

      # Type claims supported by this HealthCard subclass
      # @return [Array] an array of Strings with all the supported type claims
      def types
        @types ||= VC_TYPE.dup
      end

      # Check if this class supports the given type claim(s)
      # @param type [Array, String] A type as defined by the SMART Health Cards framework
      # @return [Boolean] Whether or not the type param is included in the types supported by the HealthCard (sub)class
      def supports_type?(*type)
        !types.intersection(type).empty?
      end
    end

    allow FHIR::Meta, %w[security]
    disallow FHIR::CodeableConcept, %w[text]
    disallow FHIR::Coding, %w[display]

    # Create a HealthCard
    #
    # @param bundle [FHIR::Bundle] VerifiableCredential containing a fhir bundle
    # @param issuer [String] The url from the Issuer of the HealthCard
    def initialize(bundle:, issuer: nil)
      raise InvalidPayloadException unless bundle.is_a?(FHIR::Bundle)

      @issuer = issuer
      @bundle = bundle
    end

    # A Hash matching the VC structure specified by https://smarthealth.cards/#health-cards-are-encoded-as-compact-serialization-json-web-signatures-jws
    # @return [Hash]
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

    # A compressed version of the FHIR::Bundle based on the SMART Health Cards frame work and any other constraints
    # defined by a subclass
    # @return String compressed payload
    def to_s
      HealthCard.compress_payload(to_json)
    end

    # A minified JSON string matching the VC structure specified by https://smarthealth.cards/#health-cards-are-encoded-as-compact-serialization-json-web-signatures-jws
    # @return [String] JSON string
    def to_json(*_args)
      JSON.minify(to_hash.to_json)
    end

    # Processes the bundle according to https://smarthealth.cards/#health-cards-are-small and returns
    # a Hash with equivalent values
    # @return [Hash] A hash with the same content as the FHIR::Bundle, processed accoding
    # to SMART Health Cards framework and any constraints created by subclasses
    def strip_fhir_bundle
      return [] unless bundle.entry

      # Using this to dup the original bundle, hopefully it correctly dups everything
      new_bundle = FHIR::Bundle.new(bundle.to_hash)
      url_map = redefine_uris(new_bundle)

      walk_resource(new_bundle) do |value, type|
        case type
        when 'Reference'
          value.reference = process_reference(url_map, value)
        when 'Resource'
          value.id = nil
          value.text = nil
          value.meta = nil unless value.meta&.security
        end

        handle_allowable(value)
        handle_disallowable(value)
      end

      new_bundle
    end

    private

    def redefine_uris(bundle)
      url_map = {}
      resource_count = 0
      bundle.entry.each do |entry|
        old_url = entry.fullUrl
        new_url = "resource:#{resource_count}"
        url_map[old_url] = new_url
        entry.fullUrl = new_url
        resource_count += 1
      end
      url_map
    end

    def walk_resource(resource, &block)
      resource.class::METADATA.each do |field_name, meta|
        type = meta['type']
        local_name = meta.fetch :local_name, field_name
        values = [resource.instance_variable_get("@#{local_name}")].flatten.compact
        next if values.empty?

        values.each do |value|
          yield value, type
          walk_resource value, &block unless FHIR::PRIMITIVES.include? type
        end
      end
    end

    def handle_allowable(resource)
      klass = resource.class
      allowable = self.class.allowable[klass]

      return unless allowable

      allowed = resource.to_hash.select! { |att| allowable.include?(att) }

      resource.from_hash(allowed)
    end

    def handle_disallowable(resource)
      klass = resource.class
      disallowable = self.class.disallowable[klass]

      return unless disallowable

      allowed = resource.to_hash.delete_if { |att| disallowable.include?(att) }

      resource.from_hash(allowed)
    end

    def process_reference(url_map, ref)
      url = ref.reference

      return unless url

      new_url = url_map.key?(url) ? url_map[url] : url_map["#{issuer}/#{url}"]

      raise InvalidBundleReferenceException, url unless new_url

      new_url
    end
  end
end
