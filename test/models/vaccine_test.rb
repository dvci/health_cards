# frozen_string_literal: true

require 'test_helper'

class VaccineTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true

  test 'vaccine fixtures exist' do
    assert_not_empty Vaccine.all
  end

  test 'vaccines prepend code with CVX code system' do
    Vaccine.all.each do |v|
      assert v.code.starts_with? Vaccine::CVX
    end
  end

  test 'pfizer vaccine exists from fixtures' do
    assert vaccines(:pfizer)
  end
end
