# frozen_string_literal: true

require 'test_helper'

class LabResultTest < ActiveSupport::TestCase
  test 'serialization' do
    pat = Patient.create!(given: 'foo')
    lab = LabResult.create(code: '94508-9', status: 'amended', result: '260385009', effective: Time.zone.now,
                           patient: pat)
    assert_not lab.new_record?, lab.errors.full_messages
    assert_equal FHIR::Observation, LabResult.first.json.class
  end
end
