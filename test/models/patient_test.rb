# frozen_string_literal: true

require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  test 'json serialization' do
    p1 = Patient.create(given: 'Foo', family: 'Bar', gender: 'male',
                        birth_date: Time.zone.today)
    assert p1.valid?, p1.errors.full_messages.join(', ')
    p2 = Patient.find(p1.id)
    p1.attributes.each do |attr, val|
      assert_equal val, p2.send(attr), "Patient #{attr} not the same"
    end
  end

  test 'invalid json validation' do
    assert_raises(ActiveRecord::SerializationTypeMismatch) do
      Patient.new(json: "asdfasdasdf'jkl")
    end
  end

  test 'bundle creation' do
    @pat = Patient.create(given: 'foo')
    vax = Vaccine.create(code: 'a', name: 'b')
    @pat.immunizations.create(occurrence: Time.now, vaccine: vax)
    bundle = @pat.to_bundle
    assert_equal 2, bundle.entry.size
    assert_equal FHIR::Patient, bundle.entry[0].class
    assert_equal FHIR::Immunization, bundle.entry[1].class
    assert_equal 'collection', bundle.type
  end

  test 'invalid fhir json' do
    patient = Patient.create(json: FHIR::Patient.new(gender: 'INVALID GENDER'))
    assert patient.new_record?
  end

  test 'update patient' do
    patient = Patient.create
    given = 'foo'
    assert patient.update(given: given)
    patient.reload
    assert_equal given, patient.given
  end
end
