# frozen_string_literal: true

require 'test_helper'

class VaccineTest < ActiveSupport::TestCase
  setup do
    Vaccine.seed
  end

  test 'vaccines seeded in test database' do
    assert Vaccine.find_by(code: '207')
    assert Vaccine.find_by(code: '208')
    assert Vaccine.find_by(code: '212')
  end
end
