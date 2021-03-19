# frozen_string_literal: true

require 'test_helper'

class ImmunizationTest < ActiveSupport::TestCase
  setup do
    @pat = Patient.create(given: 'Foo')
    @vax = Vaccine.create(code: 'a', name: 'b')
  end

  test 'json serialization of vax data' do
    imm = @pat.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    assert_not imm.new_record?, imm.errors.full_messages.join(', ')
    assert_equal @vax.code, imm.json.vaccineCode.coding[0].code
  end
end
