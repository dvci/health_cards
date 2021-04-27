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

  test 'minified entries' do
    bundle = @card.strip_fhir_bundle
    assert_equal 3, bundle['entry'].size
    patient = FHIR::Patient.new(bundle['entry'][0]['resource'])
    imm = FHIR::Immunization.new(bundle['entry'][1]['resource'])

    assert_equal 'Jane', patient.name.first.given.first
    assert_equal '1961-01-20', patient.birthDate
    assert_nil patient.gender

    assert_equal '208', imm.vaccineCode.coding.first.code
  end
end
