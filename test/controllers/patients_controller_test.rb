# frozen_string_literal: true

require 'test_helper'

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attributes = { given: 'foo', family: 'bar', gender: 'male' }
    @patient = Patient.create(@attributes)
    assert_not @patient.new_record?
  end

  test 'should get index' do
    get patients_url
    assert_response :success
  end

  test 'should get new' do
    get new_patient_url
    assert_response :success
  end

  test 'should create patient' do
    assert_difference('Patient.count') do
      post patients_url, params: { patient: @attributes }
    end
    new_patient = Patient.last

    assert_attributes_equal(@patient, new_patient, @attributes.keys)

    assert_redirected_to patient_url(new_patient)
  end

  test 'should show patient' do
    get patient_url(@patient)
    assert_response :success
  end

  test 'should get edit' do
    get edit_patient_url(@patient)
    assert_response :success
  end

  test 'should update patient' do
    patch patient_url(@patient), params: { patient: { json: @patient.json } }
    assert_redirected_to patient_url(@patient)
  end

  test 'should destroy patient' do
    assert_difference('Patient.count', -1) do
      delete patient_url(@patient)
    end

    assert_redirected_to patients_url
  end
end
