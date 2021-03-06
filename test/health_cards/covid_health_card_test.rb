# frozen_string_literal: true

require 'test_helper'

class COVIDHealthCardTest < ActiveSupport::TestCase
  setup do
    @bundle = FHIR::Bundle.new(load_json_fixture('covid-bundle'))
    @card = rails_issuer.create_health_card(@bundle, type: HealthCards::COVIDHealthCard)
  end

  test 'is of custom type' do
    assert @card.is_a?(HealthCards::COVIDHealthCard)
  end

  test 'includes correct types' do
    HealthCards::COVIDHealthCard.types.include?(HealthCards::CardTypes::VC_TYPE[0])
    HealthCards::COVIDHealthCard.types.include?('https://smarthealth.cards#covid19')
  end

  test 'includes required credential attributes in hash' do
    hash = @card.to_hash
    type = hash.dig(:vc, :type)
    assert_not_nil type
    assert_includes type, HealthCards::CardTypes::VC_TYPE[0]
    assert_includes type, 'https://smarthealth.cards#covid19'
    assert_includes type, 'https://smarthealth.cards#immunization'

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
    assert HealthCards::COVIDHealthCard.supports_type? ['https://smarthealth.cards#covid19',
                                                        'https://smarthealth.cards#immunization']
  end

  test 'minified entries' do
    bundle = @card.strip_fhir_bundle
    assert_equal 3, bundle.entry.size
    patient = bundle.entry[0].resource
    imm = bundle.entry[1].resource

    assert_equal 'Jane', patient.name.first.given.first
    assert_equal '1961-01-20', patient.birthDate
    assert_nil patient.gender

    assert_equal '208', imm.vaccineCode.coding.first.code
  end
end
