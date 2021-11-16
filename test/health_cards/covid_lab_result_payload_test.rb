# frozen_string_literal: true

require 'test_helper'

class COVIDLabResultPayloadTest < ActiveSupport::TestCase
  setup do
    bundle = FHIR::Bundle.new(load_json_fixture('example-covid-lab-result-bundle'))
    @lab_result_card = HealthCards::COVIDLabResultPayload.new(bundle: bundle, issuer: 'http://example.org')
  end

  test 'is of custom type' do
    assert @lab_result_card.is_a?(HealthCards::COVIDLabResultPayload)
  end

  test 'includes correct types' do
    HealthCards::COVIDLabResultPayload.types.include?('https://smarthealth.cards#health-card')
    HealthCards::COVIDLabResultPayload.types.include?('https://smarthealth.cards#covid19')
    HealthCards::COVIDLabResultPayload.types.include?('https://smarthealth.cards#laboratory')
  end

  test 'supports laboratory type' do
    assert HealthCards::COVIDLabResultPayload.supports_type?('https://smarthealth.cards#laboratory')
  end

  test 'minified lab result entries' do
    bundle = @lab_result_card.strip_fhir_bundle
    assert_equal 2, bundle.entry.size
    obs = bundle.entry[1].resource

    assert_equal 'final', obs.status
    assert_equal '2021-02-17', obs.effectiveDateTime
    assert_nil obs.issued
  end
end
