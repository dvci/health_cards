# frozen_string_literal: true

require 'test_helper'
FILEPATH_PAYLOAD_MINIFIED = 'example-jws-payload-minified'

class HealthCardsHelperTest < ActiveSupport::TestCase
  include HealthCardsHelper

  setup do
    Vaccine.create(code: '207')
    @jws_payload = load_json_fixture(FILEPATH_PAYLOAD_MINIFIED)
  end

  test 'Patient is not created when Patient resource is not in bundle' do
    @jws_payload['vc']['credentialSubject']['fhirBundle']['entry'].delete_at(0)
    patient = create_patient_from_jws @jws_payload
    assert patient.nil?
  end

  test 'Patient created when Patient resource is in bundle' do
    patient = create_patient_from_jws @jws_payload
    assert_not_nil patient
  end
end
