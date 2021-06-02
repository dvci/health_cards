# frozen_string_literal: true

require 'test_helper'

class QRCodesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: '207')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
  end

  test 'start scanning' do
    get(new_qr_code_path)

    assert_response :success
  end

  # test 'submit scanning' do

  # end

  test 'qr code image (single)' do
    get(patient_qr_code_path(@patient, 1, format: :png))
    assert_nothing_raised do
      ChunkyPNG::Image.from_blob(response.body)
    end
    assert_response :success
  end

  test 'qr code image (not found)' do
    get(patient_qr_code_path(@patient, 2, format: :png))
    assert_raises ChunkyPNG::SignatureMismatch do
      ChunkyPNG::Image.from_blob(response.body)
    end
    assert_response :not_found
  end
end
