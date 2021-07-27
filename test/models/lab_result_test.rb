# frozen_string_literal: true

require 'test_helper'

class LabResultTest < ActiveSupport::TestCase
  test 'serialization' do
    pat = Patient.create!(given: 'foo')
    LabResult.create!(code: '1234', status: 'amended', result: '5678', effective: Time.zone.now, patient: pat)
    assert_equal FHIR::Observation, LabResult.all.first.json.class
  end
end
