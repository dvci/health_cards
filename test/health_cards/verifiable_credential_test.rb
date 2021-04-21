# frozen_string_literal: true

require 'test_helper'
require 'health_cards/verifiable_credential'

FILEPATH_JWS_PAYLOAD = 'test/fixtures/files/example-verbose-jws-payload.json'

URL_HASH = { 'urn:uuid:643e199d-1aaf-49af-8a3b-c7ae375d11ce' => 'resource:0',
             'urn:uuid:4fe4f8d4-9b6e-4780-8ea5-6b5791230c85' => 'resource:1',
             'urn:uuid:911791c4-5131-44ba-85bd-8e6bdf652fd4' => 'resource:2' }.freeze

MOCK_JSON = { key1: 'value1', key2: 'value2' }.freeze

class VerifiableCredentialTest < ActiveSupport::TestCase
  FILEPATH_JWS_PAYLOAD = 'test/fixtures/files/example-verbose-jws-payload.json'
  BUNDLE_SKELETON = FHIR::Bundle.new.freeze

  setup do
    file = File.read(FILEPATH_JWS_PAYLOAD)
    @verbose_bundle = JSON.parse(file)
    @verbose_vc = HealthCards::VerifiableCredential.new('http://example.com', @verbose_bundle)
  end

  test 'without subject identifier' do
    @vc = HealthCards::VerifiableCredential.new('http://example.com', BUNDLE_SKELETON)
    assert_equal @vc.fhir_bundle, BUNDLE_SKELETON
  end

  test 'redefine_uris populates Bundle.entry.fullUrl elements with short resource-scheme URIs' do
    stripped_bundle = @verbose_vc.strip_fhir_bundle

    resource_nums = []
    new_entries = stripped_bundle['entry']
    new_entries.each do |resource|
      url = resource['fullUrl']
      resource, num = url.split(':')
      assert_equal('resource', resource)
      resource_nums.push(num)
    end

    inc_array = Array.new(new_entries.length, &:to_s)
    assert_equal(resource_nums, inc_array)
  end

  test 'update_elements strips resource-level "id", "meta", and "text" elements from the FHIR Bundle' do
    stripped_bundle = @verbose_vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']

    stripped_resources.each do |resource|
      assert_not(resource.key?('id'))
      assert_not(resource.key?('meta'))
      assert_not(resource.key?('text'))
    end
  end

  test 'update_nested_elements strips any "CodeableConcept.text" and "Coding.display" elements from the FHIR Bundle' do
    stripped_bundle = @verbose_vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']

    resource_with_codeable_concept = stripped_resources[2]
    codeable_concept = resource_with_codeable_concept['resource']['valueCodeableConcept']
    coding = codeable_concept['coding'][0]

    assert_not(codeable_concept.key?('text'))
    assert_not(coding.key?('display'))
  end

  test 'update_nested_elements populates Reference.reference elements with short resource-scheme URIs' do
    stripped_bundle = @verbose_vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']
    resource_with_reference = stripped_resources[2]

    reference = resource_with_reference['resource']['subject']['reference']
    assert(reference.start_with?('resource:') && (reference.length <= 12))
  end

  test 'compress_payload applies a raw deflate compression and allows for the original JWS payload to be restored' do
    @vc = HealthCards::VerifiableCredential.new('http://example.com', BUNDLE_SKELETON)
    original_vc = JSON.parse(@vc.minify_payload)

    compressed_vc = @vc.compress_credential

    new_vc = HealthCards::VerifiableCredential.decompress_credential(compressed_vc)
    new_cs = new_vc.credential.deep_stringify_keys

    original_vc.each_pair do |k, v|
      assert_equal v, new_cs[k]
    end
  end
end
