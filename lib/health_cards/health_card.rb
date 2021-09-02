# frozen_string_literal: true

require 'zlib'
require 'uri'

require 'health_cards/attribute_filters'
require 'health_cards/card_types'

module HealthCards
  # A HealthCard which implements the credential claims specified by https://smarthealth.cards/
  class HealthCard
    include HealthCards::AttributeFilters
    extend HealthCards::CardTypes

    FHIR_REF_REGEX = %r{((http|https)://([A-Za-z0-9\-\\.:%$]*/)+)?(
      Account|ActivityDefinition|AdverseEvent|AllergyIntolerance|Appointment|AppointmentResponse|AuditEvent|Basic|
      Binary|BiologicallyDerivedProduct|BodyStructure|Bundle|CapabilityStatement|CarePlan|CareTeam|CatalogEntry|
      ChargeItem|ChargeItemDefinition|Claim|ClaimResponse|ClinicalImpression|CodeSystem|Communication|
      CommunicationRequest|CompartmentDefinition|Composition|ConceptMap|Condition|Consent|Contract|Coverage|
      CoverageEligibilityRequest|CoverageEligibilityResponse|DetectedIssue|Device|DeviceDefinition|DeviceMetric
      |DeviceRequest|DeviceUseStatement|DiagnosticReport|DocumentManifest|DocumentReference|EffectEvidenceSynthesis|
      Encounter|Endpoint|EnrollmentRequest|EnrollmentResponse|EpisodeOfCare|EventDefinition|Evidence|EvidenceVariable|
      ExampleScenario|ExplanationOfBenefit|FamilyMemberHistory|Flag|Goal|GraphDefinition|Group|GuidanceResponse|
      HealthcareService|ImagingStudy|Immunization|ImmunizationEvaluation|ImmunizationRecommendation|
      ImplementationGuide|InsurancePlan|Invoice|Library|Linkage|List|Location|Measure|MeasureReport|Media|Medication|
      MedicationAdministration|MedicationDispense|MedicationKnowledge|MedicationRequest|MedicationStatement|
      MedicinalProduct|MedicinalProductAuthorization|MedicinalProductContraindication|MedicinalProductIndication|
      MedicinalProductIngredient|MedicinalProductInteraction|MedicinalProductManufactured|MedicinalProductPackaged|
      MedicinalProductPharmaceutical|MedicinalProductUndesirableEffect|MessageDefinition|MessageHeader|
      MolecularSequence|NamingSystem|NutritionOrder|Observation|ObservationDefinition|OperationDefinition|
      OperationOutcome|Organization|OrganizationAffiliation|Patient|PaymentNotice|PaymentReconciliation|Person|
      PlanDefinition|Practitioner|PractitionerRole|Procedure|Provenance|Questionnaire|QuestionnaireResponse|
      RelatedPerson|RequestGroup|ResearchDefinition|ResearchElementDefinition|ResearchStudy|ResearchSubject|
      RiskAssessment|RiskEvidenceSynthesis|Schedule|SearchParameter|ServiceRequest|Slot|Specimen|SpecimenDefinition|
      StructureDefinition|StructureMap|Subscription|Substance|SubstanceNucleicAcid|SubstancePolymer|SubstanceProtein|
      SubstanceReferenceInformation|SubstanceSourceMaterial|SubstanceSpecification|SupplyDelivery|SupplyRequest|Task|
      TerminologyCapabilities|TestReport|TestScript|ValueSet|VerificationResult|VisionPrescription)/
      [A-Za-z0-9\-.]{1,64}(/_history/[A-Za-z0-9\-.]{1,64})?}x.freeze

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

        raise HealthCards::InvalidCredentialError unless bundle_hash

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

      # Sets/Gets the fhir version that will be passed through to the credential created by an instnace of
      # this HealthCard (sub)class
      # @param ver [String] FHIR Version supported by this HealthCard (sub)class. Leaving this param out
      # will only return the current value
      # value (used as a getter)
      # @return [String] Current FHIR version supported
      def fhir_version(ver = nil)
        if @fhir_version.nil? && ver.nil?
          @fhir_version = superclass.fhir_version unless self == HealthCards::HealthCard
        elsif ver
          @fhir_version = ver
        end
        @fhir_version
      end
    end

    fhir_version '4.0.1'

    additional_types 'https://smarthealth.cards#health-card'

    allow type: FHIR::Meta, attributes: %w[security]

    disallow attributes: %w[id text]
    disallow type: FHIR::CodeableConcept, attributes: %w[text]
    disallow type: FHIR::Coding, attributes: %w[display]

    # Create a HealthCard
    #
    # @param bundle [FHIR::Bundle] VerifiableCredential containing a fhir bundle
    # @param issuer [String] The url from the Issuer of the HealthCard
    def initialize(bundle:, issuer: nil)
      raise InvalidPayloadError unless bundle.is_a?(FHIR::Bundle) # && bundle.valid?

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
            fhirBundle: strip_fhir_bundle.to_hash
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
      to_hash.to_json
    end

    # Processes the bundle according to https://smarthealth.cards/#health-cards-are-small and returns
    # a Hash with equivalent values
    # @return [Hash] A hash with the same content as the FHIR::Bundle, processed accoding
    # to SMART Health Cards framework and any constraints created by subclasses
    def strip_fhir_bundle
      return [] unless bundle.entry

      new_bundle = duplicate_bundle
      url_map = redefine_uris(new_bundle)

      new_bundle.entry.each do |entry|
        entry.each_element do |value, metadata, _|
          case metadata['type']
          when 'Reference'
            value.reference = process_reference(url_map, entry, value)
          when 'Resource'
            value.meta = nil unless value.meta&.security
          end

          handle_allowable(value)
          handle_disallowable(value)
        end
      end

      new_bundle
    end

    private

    def duplicate_bundle
      FHIR::Bundle.new(bundle.to_hash)
    end

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

    def process_reference(url_map, entry, ref)
      entry_url = URI(url_map.key(entry.fullUrl))
      ref_url = ref.reference

      return unless ref_url

      return url_map[ref_url] if url_map[ref_url]

      fhir_base_url = FHIR_REF_REGEX.match(entry_url.to_s)[1]
      full_url = URI.join(fhir_base_url, ref_url).to_s

      new_url = url_map[full_url]

      raise InvalidBundleReferenceError, full_url unless new_url

      new_url
    end
  end
end
