# frozen_string_literal: true

require 'test_helper'
require 'health_cards/verifiable_credential'

FILEPATH_JWS_PAYLOAD = 'test/fixtures/files/example-verbose-jws-payload.json'

MOCK_JSON = { key1: 'value1', key2: 'value2' }.freeze

class VerifiableCredentialTest < ActiveSupport::TestCase
  setup do
    @bundle = { resourceType: 'Bundle', entries: [] }

    # @dummy_class = Class.new
    # @dummy_class.extend(HealthCards::VerifiableCredential)

    file = File.read(FILEPATH_JWS_PAYLOAD)
    jws_payload = JSON.parse(file)
    @verbose_bundle = jws_payload['vc']['credentialSubject']['fhirBundle']
    @entries = @verbose_bundle['entry']
  end

  test 'with subject identified' do
    @subject = 'foo'
    @vc = HealthCards::VerifiableCredential.new(@bundle, @subject)

    assert_equal @vc.credential.dig(:credentialSubject, :fhirBundle), @bundle
    assert_equal @vc.credential.dig(:credentialSubject, :id), @subject
  end

  test 'without subject identifier' do
    @vc = HealthCards::VerifiableCredential.new(@bundle)
    assert_equal @vc.credential.dig(:credentialSubject, :fhirBundle), @bundle
    assert_nil @vc.credential.dig(:credentialSubject, :id)
  end

  test 'redefine_uris populates Bundle.entry.fullUrl elements with short resource-scheme URIs' do
    @vc = HealthCards::VerifiableCredential.new(@verbose_bundle)
    stripped_bundle = @vc.strip_fhir_bundle

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

  test 'update_elements strips resource-level "id", "meta", and text elements from the FHIR Bundle' do
    @vc = HealthCards::VerifiableCredential.new(@verbose_bundle)

    stripped_bundle = @vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']

    stripped_resources.each do |resource|
      assert_not(resource.key?('id'))
      assert_not(resource.key?('meta'))
      assert_not(resource.key?('text'))
    end
  end

  test 'update_nested_elements strips any "CodeableConcept.text" and "Coding.display" elements from the FHIR Bundle' do
    @vc = HealthCards::VerifiableCredential.new(@verbose_bundle)
    stripped_bundle = @vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']

    stripped_resource = stripped_resources[2]
    codeable_concept = stripped_resource['resource']['valueCodeableConcept']
    coding = codeable_concept['coding'][0]

    assert_not(codeable_concept.key?('text'))
    assert_not(coding.key?('display'))
  end

  test 'update_nested_elements populates Reference.reference elements with short resource-scheme URIs' do
    @vc = HealthCards::VerifiableCredential.new(@verbose_bundle)
    stripped_bundle = @vc.strip_fhir_bundle
    stripped_resources = stripped_bundle['entry']
    resource_with_reference = stripped_resources[2]

    reference = resource_with_reference['resource']['subject']['reference']
    assert(reference.start_with?('resource:') && (reference.length <= 12))
  end

  test 'compress_payload applies a raw deflate compression and allows for the original JWS payload to be restored' do
    @vc = HealthCards::VerifiableCredential.new(@bundle)
    original_vc = JSON.parse(@vc.minify_payload)

    compressed_vc = @vc.compress_credential

    decoded = Base64.decode64(compressed_vc)
    reinflated_vc = JSON.parse(Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(decoded))

    reinflated_vc.delete('proof')
    original_vc.delete('proof')

    assert_equal(reinflated_vc, original_vc)
  end
end
