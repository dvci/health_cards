# frozen_string_literal: true

require 'test_helper'

class COVIDImmunizationCardTest < ActiveSupport::TestCase
  setup do
    bundle = FHIR::Bundle.new(load_json_fixture('example-covid-immunization-bundle'))
    @immunization_card = rails_issuer.create_health_card(bundle, type: HealthCards::COVIDImmunizationCard)
  end

  test 'is of custom type' do
    assert @immunization_card.is_a?(HealthCards::COVIDImmunizationCard)
  end

  test 'includes correct types' do
    HealthCards::COVIDImmunizationCard.types.include?('https://smarthealth.cards#health-card')
    HealthCards::COVIDImmunizationCard.types.include?('https://smarthealth.cards#covid19')
    HealthCards::COVIDImmunizationCard.types.include?('https://smarthealth.cards#immunization')
  end

  
  test 'supports immunization type' do 
    assert HealthCards::COVIDImmunizationCard.supports_type?('https://smarthealth.cards#immunization')
  end

  test 'minified immunization entries' do
    bundle = @immunization_card.strip_fhir_bundle
    imm = bundle.entry[1].resource

    assert_equal '208', imm.vaccineCode.coding.first.code
    assert_equal '0000002', imm.lotNumber
    assert_equal 'ABC General Hospital', imm.performer[0].actor.display
    assert_nil imm.primarySource
  end
end