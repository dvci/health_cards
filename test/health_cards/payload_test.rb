# frozen_string_literal: true

require 'test_helper'

class PayloadTest < ActiveSupport::TestCase
  class TestCOVIDLabPayload < HealthCards::Payload
    additional_types 'https://smarthealth.cards#covid19'
    additional_types 'https://smarthealth.cards#laboratory'
  end

  setup do
    # from https://smarthealth.cards/examples/example-00-d-jws.txt

    @issuer = 'https://smarthealth.cards/examples/issuer'
    @bundle = bundle_payload

    file = File.read('test/fixtures/files/example-verbose-jws-payload.json')
    @bundle = FHIR.from_contents(file)
    @health_card = HealthCards::Payload.new(issuer: @issuer, bundle: @bundle)
  end

  ## Constructor

  test 'Payload can be created from a Bundle' do
    assert_not_nil @health_card.bundle
    assert @health_card.bundle.is_a?(FHIR::Bundle)
  end

  test 'Payload can be created without allows' do
    bundle = FHIR.from_contents(File.read('test/fixtures/files/example-covid-lab-result-bundle.json'))
    test_card = TestCOVIDLabPayload.new(issuer: @issuer, bundle: bundle)
    test_card.to_hash
    test_card.to_hash(filter: false)
  end

  test 'Payload handles empty payloads' do
    compressed_payload = HealthCards::Payload.compress_payload(FHIR::Bundle.new.to_json)
    jws = HealthCards::JWS.new(header: {}, payload: compressed_payload, key: rails_private_key)
    assert_raises HealthCards::InvalidCredentialError do
      HealthCards::HealthCard.new(jws.to_s)
    end
  end

  ## Creating a Payload from a JWS

  test 'Payload can be created from a JWS' do
    jws_string = load_json_fixture('example-jws')
    card = HealthCards::HealthCard.new(jws_string)
    assert_not_nil card.bundle
    assert card.bundle.is_a?(FHIR::Bundle)
  end

  test 'Payload throws an exception when the payload is not a FHIR Bundle' do
    assert_raises HealthCards::InvalidPayloadError do
      HealthCards::Payload.new(issuer: @issuer, bundle: FHIR::Patient.new)
    end

    assert_raises HealthCards::InvalidPayloadError do
      HealthCards::Payload.new(issuer: @issuer, bundle: '{"foo": "bar"}')
    end

    assert_raises HealthCards::InvalidPayloadError do
      HealthCards::Payload.new(issuer: @issuer, bundle: 'foo')
    end
  end

  test 'includes required credential attributes in json' do
    hash = JSON.parse(@health_card.to_json)

    assert_equal @issuer, hash['iss']
    assert hash['nbf'] >= Time.now.to_i

    type = hash.dig('vc', 'type')
    assert_not_nil type
    assert_includes type, 'https://smarthealth.cards#health-card'
    bundle = hash.dig('vc', 'credentialSubject', 'fhirBundle')

    assert_not_nil bundle
    assert_nothing_raised do
      FHIR::Bundle.new(bundle)
    end
  end

  test 'export with unfiltered bundle' do
    hash = @health_card.to_hash(filter: false)
    bundle = hash.dig(:vc, :credentialSubject, :fhirBundle)

    assert_not_nil bundle
    assert_not_nil bundle['entry']
    resources = bundle['entry'].map { |e| e['resource'] }
    assert_not_nil resources[0]['telecom']
    assert_not_nil resources[1].dig('code', 'coding')[0]['display']
    assert_not_nil resources[2].dig('code', 'text')
  end

  test 'redefine_uris populates Bundle.entry.fullUrl elements with short resource-scheme URIs' do
    stripped_bundle = @health_card.strip_fhir_bundle

    resource_nums = []
    new_entries = stripped_bundle.entry
    new_entries.each do |resource|
      url = resource.fullUrl
      resource, num = url.split(':')
      assert_equal('resource', resource)
      resource_nums.push(num)
    end

    inc_array = Array.new(new_entries.length, &:to_s)
    assert_equal(resource_nums, inc_array)
  end

  test 'changes to stripped bundle do not affect bundle values' do
    original_json = @health_card.to_json
    @health_card.strip_fhir_bundle
    original_json2 = @health_card.to_json
    assert_equal original_json, original_json2
  end

  test 'do not strip name.text elements' do
    stripped_bundle = @health_card.strip_fhir_bundle
    assert_not_nil stripped_bundle.entry[0].resource.name[0].text
  end

  test 'update_elements strips resource-level "id", "meta", and "text" elements from the FHIR Bundle' do
    stripped_bundle = @health_card.strip_fhir_bundle
    stripped_entries = stripped_bundle.entry

    stripped_entries.each do |entry|
      resource = entry.resource
      assert_not(resource.id, "#{resource} has id")
      assert_not(resource.text, "#{resource} has text")
      meta = resource.meta
      if meta
        assert_equal 1, meta.to_hash.length
        assert_not_nil meta.security
      end
    end
  end

  test 'support single type' do
    assert HealthCards::Payload.supports_type?('https://smarthealth.cards#health-card')
  end

  test 'update_nested_elements strips any "CodeableConcept.text" and "Coding.display" elements from the FHIR Bundle' do
    stripped_bundle = @health_card.strip_fhir_bundle
    stripped_resources = stripped_bundle.entry

    resource_with_codeable_concept = stripped_resources[2]
    codeable_concept = resource_with_codeable_concept.resource.valueCodeableConcept
    coding = codeable_concept.coding[0]

    assert_nil codeable_concept.text
    assert_nil coding.display
  end

  test 'update_nested_elements populates Reference.reference elements with short resource-scheme URIs' do
    stripped_bundle = @health_card.strip_fhir_bundle
    stripped_resources = stripped_bundle.entry
    resource_with_reference = stripped_resources[2]

    reference = resource_with_reference.resource.subject.reference

    assert_match(/resource:[0-9]+/, reference)
  end

  test 'all reference types are replaced with short resource-scheme URIs' do
    bundle = FHIR::Bundle.new(load_json_fixture('example-logical-link-bundle'))
    card = HealthCards::Payload.new(issuer: 'http://example.org/fhir', bundle: bundle)
    assert_nothing_raised do
      new_bundle = card.strip_fhir_bundle

      assert_entry_references_match(new_bundle.entry[0], new_bundle.entry[2].resource.subject) # logical ref
      assert_entry_references_match(new_bundle.entry[0], new_bundle.entry[3].resource.subject) # full url ref
      assert_entry_references_match(new_bundle.entry[1], new_bundle.entry[4].resource.subject) # uuid ref
    end
  end

  test 'raises error when url refers to resource outside bundle' do
    bundle = FHIR::Bundle.new(load_json_fixture('example-logical-link-bundle-bad'))
    card = HealthCards::Payload.new(issuer: 'http://example.org/fhir', bundle: bundle)
    assert_raises HealthCards::InvalidBundleReferenceError do
      card.strip_fhir_bundle
    end
  end

  test 'compress_payload applies a raw deflate compression and allows for the original payload to be restored' do
    original_hc = HealthCards::Payload.new(issuer: @issuer, bundle: FHIR::Bundle.new)
    new_hc = HealthCards::Payload.from_payload(original_hc.to_s)
    assert_equal original_hc.to_hash, new_hc.to_hash
  end
end
