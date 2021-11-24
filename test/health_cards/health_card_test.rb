# frozen_string_literal: true

require 'test_helper'

class HealthCardTest < ActiveSupport::TestCase
  setup do
    @jws = load_json_fixture('example-jws')
    @card = HealthCards::HealthCard.new(@jws)
  end

  test 'json' do
    credential = JSON.parse(@card.to_json)
    vc = credential['verifiableCredential'][0]
    assert_equal @jws, vc
  end

  test 'qr codes' do
    assert_not_nil @card.code_by_ordinal(1)
  end

  test 'resource w/type' do
    patient = @card.resource(type: FHIR::Patient)
    assert_equal FHIR::Patient, patient.class
  end

  test 'resources w/type' do
    imms = @card.resources(type: FHIR::Immunization)
    assert_equal 2, imms.length
    imms.each do |i|
      assert_equal FHIR::Immunization, i.class
    end
  end

  test 'resource w/type and rules' do
    lot = 'Lot #0000001'
    imms = @card.resources(type: FHIR::Immunization) { |i| i.lotNumber == lot }
    assert_equal 1, imms.length
    assert_equal lot, imms.first.lotNumber
  end

  test 'only rules' do
    resources = @card.resources { |r| !r.id.nil? }
    assert_equal 0, resources.length
  end
end
