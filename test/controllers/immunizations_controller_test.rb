# frozen_string_literal: true

require 'test_helper'

class ImmunizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create
    @vaccine = Vaccine.create(code: 'a', name: 'b')
    @immunization = @patient.immunizations.create(vaccine: @vaccine, occurrence: Time.zone.now)
  end

  test 'should get new' do
    get new_patient_immunization_url(@patient)
    assert_response :success
  end

  test 'should create immunization' do
    assert_difference('Immunization.count') do
      post patient_immunizations_url(@patient),
	   params: { immunization: { lot_number: @immunization.lot_number, occurrence: @immunization.occurrence,
				     vaccine_id: @immunization.vaccine_id } }
    end

    assert_redirected_to patient_path(@patient)
  end

  test 'should get edit' do
    get edit_patient_immunization_path(@patient, @immunization)
    assert_response :success
  end

  test 'should update immunization' do
    patch patient_immunization_url(@patient, @immunization),
	  params: { immunization: { lot_number: @immunization.lot_number, occurrence: @immunization.occurrence,
				    patient: @immunization.patient, vaccine: @immunization.vaccine } }
    assert_redirected_to patient_path(@patient)
  end

  test 'should destroy immunization' do
    assert_difference('Immunization.count', -1) do
      delete patient_immunization_url(@patient, @immunization)
    end

    assert_redirected_to patient_path(@patient)
  end
end
