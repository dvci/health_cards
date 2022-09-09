# frozen_string_literal: true

require 'test_helper'

class MonkeypoxImmunizationPayloadTest < ActiveSupport::TestCase
  setup do
    bundle = FHIR::Bundle.new(load_json_fixture('example-monkeypox-immunization-bundle'))
    @payload = HealthCards::MonkeypoxImmunizationPayload.new(bundle: bundle, issuer: 'http://example.org')
  end

  test 'is of custom type' do
    assert @payload.is_a?(HealthCards::MonkeypoxImmunizationPayload)
  end

  test 'includes correct types' do
    assert_includes HealthCards::MonkeypoxImmunizationPayload.types, 'https://smarthealth.cards#health-card'
    assert_includes HealthCards::MonkeypoxImmunizationPayload.types, 'https://smarthealth.cards#monkeypox'
    assert_includes HealthCards::MonkeypoxImmunizationPayload.types, 'https://smarthealth.cards#immunization'
  end

  test 'supports immunization type' do
    assert HealthCards::MonkeypoxImmunizationPayload.supports_type?('https://smarthealth.cards#immunization')
  end

  test 'minified immunization entries' do
    bundle = @payload.strip_fhir_bundle
    imm = bundle.entry[1].resource

    assert_equal '206', imm.vaccineCode.coding.first.code
    assert_equal '0000002', imm.lotNumber
    assert_equal 'ABC General Hospital', imm.performer[0].actor.display
    assert_nil imm.primarySource
  end
end
