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

  test 'should get new with demo data' do
    get new_patient_url, params: { patient: @attributes }
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

  test 'should not create patient' do
    assert_no_difference('Patient.count') do
      post patients_url, params: { patient: { gender: 'foo' } }
    end

    assert_response :unprocessable_entity
  end

  test 'should show patient' do
    get patient_url(@patient)
    assert_response :success
  end

  test 'show fhir patient' do
    get fhir_patient_url(@patient, format: :fhir_json)
    fhir = FHIR.from_contents(response.body)
    assert fhir.valid?
    assert_response :success
  end

  test 'show fhir patient as json' do
    get fhir_patient_url(@patient, format: :json)
    fhir = FHIR.from_contents(response.body)
    assert fhir.valid?
    assert_response :success
  end

  test 'should get edit' do
    get edit_patient_url(@patient)
    assert_response :success
  end

  test 'should update patient' do
    @attributes[:given] = 'baz'
    patch patient_url(@patient), params: { patient: @attributes }

    @patient.reload
    assert_equal @attributes[:given], Patient.find(@patient.id).given

    assert_redirected_to patient_url(@patient)
  end

  test 'should not update patient' do
    gender = 'NOT A VALID GENDER'
    patch patient_url(@patient), params: { patient: { gender: gender } }
    assert_not_equal gender, @patient.reload.gender
    assert_response :unprocessable_entity
  end

  test 'should destroy patient' do
    assert_difference('Patient.count', -1) do
      delete patient_url(@patient)
    end

    assert_redirected_to patients_url
  end
end
