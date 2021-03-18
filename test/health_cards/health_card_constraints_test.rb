# frozen_string_literal: true

require 'test_helper'
require 'pp'
# require 'hash_dig_and_collect'

require 'health_cards/health_card_constraints'

FILEPATH = 'test/fixtures/files/vc-c19-pcr-jwt-payload.json'

URL_HASH = { 'urn:uuid:643e199d-1aaf-49af-8a3b-c7ae375d11ce' => 'Resource:0',
             'urn:uuid:4fe4f8d4-9b6e-4780-8ea5-6b5791230c85' => 'Resource:1',
             'urn:uuid:911791c4-5131-44ba-85bd-8e6bdf652fd4' => 'Resource:2' }.freeze

module HealthCards
  class HealthCardConstraintsTest < ActiveSupport::TestCase
    class DummyClass
      include HealthCards::HealthCardConstraints
    end

    setup do
      @dummy_class = Class.new
      @dummy_class.extend(HealthCards::HealthCardConstraints)

      file = File.read(FILEPATH)
      @jws_payload = JSON.parse(file)

      @bundle = @jws_payload['vc']['credentialSubject']['fhirBundle']
      @entries = @bundle['entry']
    end

    test 'Bundle.entry.fullUrl elements are populated with short resource-scheme URIs (e.g., {"fullUrl": "resource:0})' do
      new_entries, url_map = @dummy_class.update_uris(@entries)
      resource_nums = []
      new_entries.each do |resource|
        url = resource['fullUrl']
        resource, num = url.split(':')
        assert_equal('Resource', resource)
        resource_nums.push(num)
      end

      inc_array = Array.new(new_entries.length, &:to_s)
      assert_equal(resource_nums, inc_array)
    end

    test 'Reference.reference elements are populated with short resource-scheme URIs (e.g., {"patient": {"reference": "resource:0"}})' do
      new_entries = @dummy_class.update_links(@entries, URL_HASH)
      # puts new_entries.dig_and_collect('fullUrl')
      new_entries.each do |e|
        # puts e
        # thing =  e.dig_and_collect("id")
      end
    end
  end
end
