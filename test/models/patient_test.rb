# frozen_string_literal: true

require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  test 'json serialization' do
    p1 = Patient.create(given: 'Foo', family: 'Bar', gender: 'male',
                        birth_date: Time.zone.today)
    assert p1.valid?, p1.errors.full_messages.join(', ')
    p2 = Patient.find(p1.id)
    assert_equal p1.given, p2.given
    assert_equal p1.family, p2.family
    assert_equal p1.gender, p2.gender
    assert_equal p1.birth_date, p2.birth_date
  end

  test 'invalid json validation' do
    assert_raises(ActiveRecord::SerializationTypeMismatch) do
      Patient.create(json: "asdfasdasdf'jkl")
    end
  end

  test 'use name.text if no given name' do
    text = 'Foo'
    pat = Patient.new(json: FHIR::Patient.new(name: [{ text: text }]))
    assert_equal text, pat.given
  end

  test 'invalid fhir json' do
    patient = Patient.create(json: FHIR::Patient.new(gender: 'INVALID GENDER'))
    assert patient.new_record?
  end

  test 'payload creation from patient and immunization json' do
    patient = Patient.create(given: 'foo', birth_date: Time.zone.today)
    vax = Vaccine.create(code: 'a')
    patient.immunizations.create(vaccine: vax, occurrence: Time.zone.today)

    assert_not_nil patient.json.id
    assert_not_nil patient.immunizations.first.id

    bundle = patient.to_bundle(rails_issuer.url)

    assert bundle.valid?

    payload = HealthCards::Payload.new(bundle: bundle, issuer: 'http://example.org')

    assert_nothing_raised do
      new_bundle = payload.strip_fhir_bundle

      assert_entry_references_match(new_bundle.entry[0], new_bundle.entry[1].resource.patient)
    end
  end

  test 'test blank date' do
    patient = Patient.create(given: 'foo', birth_date: '')
    assert patient.birth_date.nil?
    assert patient.json.birthDate.nil?
  end

  test 'update patient' do
    patient = Patient.create
    given = 'foo'
    assert patient.update(given: given)
    patient.reload
    assert_equal given, patient.given
  end
end
