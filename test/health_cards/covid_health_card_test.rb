# frozen_string_literal: true

require 'test_helper'

class COVIDHealthCardTest < ActiveSupport::TestCase
  setup do
    @bundle = FHIR::Bundle.new(load_json_fixture('example-covid-immunization-bundle'))
    @card = rails_issuer.create_health_card(@bundle, type: HealthCards::COVIDHealthCard)
  end

  class COVIDHealthCardSame < HealthCards::COVIDHealthCard; end

  class COVIDHealthCardChanged < HealthCards::COVIDHealthCard
    fhir_version '4.0.2'
    additional_types 'https://smarthealth.cards#test'
  end

  test 'is of custom type' do
    assert @card.is_a?(HealthCards::COVIDHealthCard)
  end

  test 'includes correct types' do
    HealthCards::COVIDHealthCard.types.include?('https://smarthealth.cards#health-card')
    HealthCards::COVIDHealthCard.types.include?('https://smarthealth.cards#covid19')
  end

  test 'includes required credential attributes in hash' do
    hash = @card.to_hash
    type = hash.dig(:vc, :type)
    assert_not_nil type
    assert_includes type, 'https://smarthealth.cards#health-card'
    assert_includes type, 'https://smarthealth.cards#covid19'

    fhir_version = hash.dig(:vc, :credentialSubject, :fhirVersion)
    assert_not_nil fhir_version
    assert_equal HealthCards::COVIDHealthCard.fhir_version, fhir_version
  end

  test 'bundle creation' do
    @card = rails_issuer.create_health_card(@bundle, type: HealthCards::COVIDHealthCard)
    bundle = @card.bundle
    assert_equal 3, bundle.entry.size
    assert_equal 'collection', bundle.type

    patient = bundle.entry[0].resource
    assert_equal FHIR::Patient, patient.class
    assert patient.valid?

    bundle.entry[1..3].map(&:resource).each do |imm|
      assert_equal FHIR::Immunization, imm.class
      # FHIR Validator thinks references are invalid so can't validate Immunization
    end
  end

  test 'valid bundle json' do
    assert_nothing_raised do
      assert_fhir(@card.bundle.to_json, type: FHIR::Bundle, validate: false)
    end
  end

  test 'supports multiple types' do
    assert HealthCards::COVIDHealthCard.supports_type? [
      'https://smarthealth.cards#health-card', 'https://smarthealth.cards#covid19'
    ]
    assert HealthCards::COVIDImmunizationCard.supports_type?('https://smarthealth.cards#immunization')
    assert HealthCards::COVIDLabResultCard.supports_type?('https://smarthealth.cards#laboratory')
  end

  test 'minified patient entries' do
    bundle = @card.strip_fhir_bundle
    assert_equal 3, bundle.entry.size
    patient = bundle.entry[0].resource

    assert_equal 'Jane', patient.name.first.given.first
    assert_equal '1961-01-20', patient.birthDate
    assert_nil patient.gender
    assert_equal 'ghp-example', patient.identifier[0].value
  end

  test 'minified immunization entries' do
    immunization_card = rails_issuer.create_health_card(@bundle, type: HealthCards::COVIDImmunizationCard)
    bundle = immunization_card.strip_fhir_bundle
    imm = bundle.entry[1].resource

    assert_equal '208', imm.vaccineCode.coding.first.code
    assert_equal '0000002', imm.lotNumber
    assert_equal 'ABC General Hospital', imm.performer[0].actor.display
    assert_nil imm.primarySource
  end

  test 'minified lab result entries' do
    lab_bundle = FHIR::Bundle.new(load_json_fixture('example-covid-lab-result-bundle'))
    lab_card = rails_issuer.create_health_card(lab_bundle, type: HealthCards::COVIDLabResultCard)
    bundle = lab_card.strip_fhir_bundle
    assert_equal 2, bundle.entry.size
    obs = bundle.entry[1].resource

    assert_equal 'final', obs.status
    assert_equal '2021-02-17', obs.effectiveDateTime
    assert_nil obs.issued
  end

  test 'inheritance of attributes' do
    assert_equal HealthCards::COVIDHealthCard.types, COVIDHealthCardSame.types
    assert_equal HealthCards::COVIDHealthCard.fhir_version, COVIDHealthCardSame.fhir_version
    assert_equal 1, HealthCards::HealthCard.types.length
    assert_equal 2, HealthCards::COVIDHealthCard.types.length
    assert_equal 3, COVIDHealthCardChanged.types.length
    assert_equal HealthCards::COVIDHealthCard.types.length + 1, COVIDHealthCardChanged.types.length
    assert_includes COVIDHealthCardChanged.types, 'https://smarthealth.cards#test'
    assert_equal '4.0.2', COVIDHealthCardChanged.fhir_version
  end
end
