# frozen_string_literal: true

require 'test_helper'
require 'health_cards/health_card_constraints'

FILEPATH_JWS_PAYLOAD = 'test/fixtures/files/example-verbose-jws-payload.json'
FILEPATH_MINIFIED = 'test/fixtures/files/example-jws-payload-minified.json'

URL_HASH = { 'urn:uuid:643e199d-1aaf-49af-8a3b-c7ae375d11ce' => 'resource:0',
             'urn:uuid:4fe4f8d4-9b6e-4780-8ea5-6b5791230c85' => 'resource:1',
             'urn:uuid:911791c4-5131-44ba-85bd-8e6bdf652fd4' => 'resource:2' }.freeze

MOCK_JSON = { key1: 'value1', key2: 'value2' }.freeze

class HealthCardConstraintsTest < ActiveSupport::TestCase
  setup do
    @dummy_class = Class.new
    @dummy_class.extend(HealthCards::HealthCardConstraints)

    file = File.read(FILEPATH_JWS_PAYLOAD)
    jws_payload = JSON.parse(file)
    bundle = jws_payload['vc']['credentialSubject']['fhirBundle']
    @entries = bundle['entry']
  end

  test 'redefine_uris populates Bundle.entry.fullUrl elements with short resource-scheme URIs' do
    new_entries, _url_map = @dummy_class.redefine_uris(@entries)
    resource_nums = []
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
    stripped_resources = @dummy_class.update_elements(@entries, URL_HASH)
    stripped_resources.each do |resource|
      assert_not(resource.key?('id'))
      assert_not(resource.key?('meta'))
      assert_not(resource.key?('text'))
    end
  end

  test 'update_nested_elements strips any "CodeableConcept.text" and "Coding.display" elements from the FHIR Bundle' do
    wordy_resource = @entries[2]
    stripped_resource = @dummy_class.update_nested_elements(wordy_resource, URL_HASH)
    codeable_concept = stripped_resource['resource']['valueCodeableConcept']
    coding = codeable_concept['coding'][0]

    assert_not(codeable_concept.key?('text'))
    assert_not(coding.key?('display'))
  end

  test 'update_nested_elements populates Reference.reference elements with short resource-scheme URIs' do
    updated_resource = @dummy_class.update_nested_elements(@entries[2], URL_HASH)
    reference = updated_resource['resource']['subject']['reference']
    assert(reference.start_with?('resource:') && (reference.length <= 12))
  end

  test 'minify_payload removes all whitespace from the JWS Payload' do
    minified = @dummy_class.minify_payload(MOCK_JSON)
    assert_not_includes(minified, ' ')
  end

  test 'compress_payload applies a raw deflate compression and allows for the original JWS payload to be restored' do
    file = File.read(FILEPATH_MINIFIED)
    minified_payload = JSON.parse(file)
    compressed = @dummy_class.compress_payload(minified_payload)

    decoded = Base64.decode64(compressed)
    inflated = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(decoded)
    assert_equal(inflated.to_s, minified_payload.to_s)
  end
end
