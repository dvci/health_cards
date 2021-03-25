# frozen_string_literal: true

require 'test_helper'

class CovidHealthCardTest < ActiveSupport::TestCase
  setup do
    @pat = Patient.create(given: 'foo', birth_date: Time.zone.today, gender: 'male')
    @vax = Vaccine.create(code: 'a', name: 'b')
    @imm = @pat.immunizations.create(occurrence: Time.zone.now, vaccine: @vax)
    @card = CovidHealthCard.new(@pat, 'http://example-issuer.org')
    @issuer = Rails.application.config.issuer
  end

  test 'bundle creation' do
    bundle = @card.bundle
    assert_equal 2, bundle.entry.size
    assert bundle.valid?
    assert_equal FHIR::Patient, bundle.entry[0].resource.class
    assert_equal FHIR::Immunization, bundle.entry[1].resource.class
    assert_equal 'collection', bundle.type
  end

  test 'verifiable credential' do
    vc = @card.vc

    jwt = JSON::JWT.decode(vc, @issuer.public_key)
    entries = jwt.dig('credentialSubject', 'fhirBundle', 'entry')
    assert_not_nil entries
    name = entries[0].dig('resource', 'name')
    assert_not_nil name
    assert_equal @pat.given, name.first['given'].first

    vax_code = entries[1].dig('resource', 'vaccineCode', 'coding').first['code']
    assert_equal @vax.code, vax_code
  end

  test 'minified entries' do
    assert_equal 2, @card.bundle.entry.size
    patient = @card.bundle.entry[0].resource
    imm = @card.bundle.entry[1].resource

    assert_equal @pat.given, patient.name.first.given.first
    assert_equal @pat.birth_date.to_s, patient.birthDate
    assert_not patient.gender

    assert_equal @vax.code, imm.vaccineCode.coding.first.code
  end
end
