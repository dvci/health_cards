# frozen_string_literal: true

require 'test_helper'

class ImmunizationTest < ActiveSupport::TestCase
  test 'json serialization of vax data' do
    pat = Patient.create(given: 'Foo')
    vax = Vaccine.create(code: 'a', name: 'b')
    imm = pat.immunizations.create(vaccine: vax)
    assert_equal vax.code, imm.json.vaccineCode
  end
end
