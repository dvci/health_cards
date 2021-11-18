# frozen_string_literal: true

require 'test_helper'

class QRCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    (200...225).each { |i| @vax = Vaccine.create(code: i.to_s) }

    @imm = @patient.immunizations.create(vaccine: Vaccine.first, occurrence: Time.zone.today)
  end

  test 'start scanning' do
    get(new_qr_code_path)

    assert_response :success
  end

  test 'submit scanning' do
    stub_request(:get, /jwks.json/).to_return(body: HealthCards::KeySet.new(private_key.public_key).to_jwk)

    scanning_input = load_json_fixture('example-scanning-input')

    post(qr_codes_path(scanning_input))

    assert_response :success
  end

  test 'submit scanning with unknown vaccine' do
    @imm.destroy
    Vaccine.delete_all

    stub_request(:get, /jwks.json/).to_return(body: HealthCards::KeySet.new(private_key.public_key).to_jwk)

    scanning_input = load_json_fixture('example-scanning-input')

    assert_difference('Vaccine.count') do
      post(qr_codes_path(scanning_input))
    end

    assert_response :success
  end

  test 'qr code image (single)' do
    get(patient_qr_code_path(@patient, 1, format: :png))
    assert_nothing_raised do
      ChunkyPNG::Image.from_blob(response.body)
    end
    assert_response :success
  end

  test 'qr code image (multi)' do
    vax = Vaccine.all
    100.times { @patient.immunizations.create(vaccine: vax.sample, occurrence: rand(5.years).seconds.ago) }
    get(patient_qr_code_path(@patient, 1, format: :png))
    jws1 = session[:jws]
    assert_not_nil jws1
    qr = HealthCards::QRCodes.from_jws(jws1).code_by_ordinal(1).data
    assert_response :success

    response1 = response.body

    get(patient_qr_code_path(@patient, 2, format: :png))
    jws2 = session[:jws]
    assert_not_nil jws2
    qr2 = HealthCards::QRCodes.from_jws(jws2).code_by_ordinal(2).data
    assert_response :success

    response2 = response.body

    reassembled_jws = HealthCards::QRCodes.new([qr, qr2]).to_jws.to_s

    # Ensure we're returning different QR Codes, but that they are sourced from the same JWS
    assert_not_equal response1, response2
    assert_equal jws1, reassembled_jws
    assert_equal jws2, reassembled_jws
  end

  test 'qr code image (not found)' do
    get(patient_qr_code_path(@patient, 2, format: :png))
    assert_raises ChunkyPNG::SignatureMismatch do
      ChunkyPNG::Image.from_blob(response.body)
    end
    assert_response :not_found
  end
end
