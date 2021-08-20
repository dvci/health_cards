# frozen_string_literal: true

require 'test_helper'

class LabResultsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @patient = Patient.create(given: 'Foo')
    @lab_result = LabResult.create(code: '94508-9', status: 'amended', result: '260385009', effective: Time.zone.now,
                                   patient: @patient)
    assert_valid @lab_result
  end

  test 'should get new' do
    get new_patient_lab_result_url(@patient)
    assert_response :success
  end

  test 'should create lab_result' do
    assert_difference('LabResult.count') do
      post patient_lab_results_url(@patient),
           params: { lab_result: { code: @lab_result.code, status: @lab_result.status, effective: @lab_result.effective,
                                   result: @lab_result.result } }
    end

    assert_redirected_to patient_path(@patient)
  end

  test 'should show lab_result' do
    get fhir_observation_url(@lab_result, format: :fhir_json)
    assert_fhir(response.body, type: FHIR::Observation)
    assert_response :success
  end

  test 'show OperationOutcome for missing lab_result' do
    get fhir_observation_url(@lab_result, format: :fhir_json)
  end

  test 'should not create invalid lab_result' do
    assert_no_difference('LabResult.count') do
      post patient_lab_results_url(@patient),
           params: { lab_result: { code: @lab_result.code, result: @lab_result.result } }
    end

    assert_response :unprocessable_entity
  end

  test 'should get edit' do
    get edit_patient_lab_result_path(@patient, @lab_result)
    assert_response :success
  end

  test 'should update lab_result' do
    patch patient_lab_result_url(@patient, @lab_result),
          params: { lab_result: { code: @lab_result.code, status: @lab_result.status, effective: @lab_result.effective,
                                  result: @lab_result.result, patient: @lab_result.patient } }
    assert_redirected_to patient_path(@patient)
  end

  test 'should not update lab_result' do
    patch patient_lab_result_url(@patient, @lab_result),
          params: { lab_result: { code: nil, status: nil, effective: nil,
                                  result: nil } }
    assert_response :unprocessable_entity
  end

  test 'should destroy lab_result' do
    assert_difference('LabResult.count', -1) do
      delete patient_lab_result_url(@patient, @lab_result)
    end

    assert_redirected_to patient_path(@patient)
  end
end
