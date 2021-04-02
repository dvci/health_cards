# frozen_string_literal: true

require 'test_helper'

class CovidHealthCardTest < ActiveSupport::TestCase
  setup do
    @pat = Patient.create(given: 'foo', birth_date: Time.zone.today, gender: 'male')
    @vax = Vaccine.create(code: 'a', name: 'b')
    @imm = @pat.immunizations.create(occurrence: Time.zone.now, vaccine: @vax)
    @card = CovidHealthCard.new(@pat) do |record|
      url = 'example.com'

      url = "#{url}/example.com/#{record.class.name}/#{record.id}" if record
      url
    end

    @key_path = Rails.application.config.hc_key_path
    @key = Rails.application.config.hc_key
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
    vc = HealthCards::VerifiableCredential.decompress_credential(@card.vc)

    entries = vc.dig('credentialSubject', 'fhirBundle', 'entry')

    assert_not_nil entries
    name = entries[0].dig('resource', 'name')
    assert_not_nil name
    assert_equal @pat.given, name.first['given'].first

    vax_code = entries[1].dig('resource', 'vaccineCode', 'coding').first['code']
    assert_equal @vax.code, vax_code
  end

  test 'minified entries' do
    bundle = @card.bundle
    assert_equal 2, bundle.entry.size
    patient = bundle.entry[0].resource
    imm = bundle.entry[1].resource

    assert_equal @pat.given, patient.name.first.given.first
    assert_equal @pat.birth_date.to_s, patient.birthDate
    assert_not patient.gender

    assert_equal @vax.code, imm.vaccineCode.coding.first.code
  end
end
