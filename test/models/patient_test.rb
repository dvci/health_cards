# frozen_string_literal: true

require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  test 'json serialization' do
    p1 = Patient.create(given: 'Foo', family: 'Bar', gender: 'male', phone: '8675309', email: 's@s.com',
                        birth_date: Time.zone.today)
    assert p1.valid?, p1.errors.full_messages.join(', ')
    p2 = Patient.find(p1.id)
    p1.attributes.each do |attr, val|
      assert_equal val, p2.send(attr), "Patient #{attr} not the same"
    end
  end

  test 'empty patient json serialization' do
    p1 = Patient.create
    assert p1.valid?, 'Empty patient is not valid'
    Patient.find(p1.id)
  end
end
