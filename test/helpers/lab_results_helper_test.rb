# frozen_string_literal: true

require 'test_helper'

FILEPATH_EXAMPLE_VALUESET = 'test/fixtures/files/example-valueset.json'

class LabResultsHelperTest < ActiveSupport::TestCase
  include LabResultsHelper

  test 'lab_option obtaining codes correctly' do
    example_str = ValueSet.new(FILEPATH_EXAMPLE_VALUESET)
    value_set = lab_options(example_str)
    assert_not_nil value_set
    assert_equal '10828004', value_set[0][1][0][1]
    assert_equal 'http://snomed.info/sct', value_set[0][0]
    assert_equal 'Positive (qualifier value)', value_set[0][1][0][0]
  end
end
