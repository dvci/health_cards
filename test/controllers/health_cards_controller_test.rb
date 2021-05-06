# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: '207')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @key = rails_public_key
  end

  teardown do
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end

  test 'get health card download' do
    get(patient_health_card_path(@patient, format: 'smart-health-card'))

    json = JSON.parse(response.body)
    vc = json['verifiableCredential']

    assert_not_nil vc
    assert_equal 1, vc.size
    assert_jws_bundle_match(vc.first, @key, @patient, @vax)
    assert_response :success
  end

  test 'upload file' do
    file = fixture_file_upload('test/fixtures/files/example-00-e-file.smart-health-card')
    post(upload_health_cards_path, params: { health_card: file })
    assert_response :success
  end

  test 'get chunks for QR code generation' do
    get(chunks_patient_health_card_url(@patient))
    assert_response :success

    chunks = JSON.parse(response.body)
    jws = HealthCards::Chunking.assemble_jws chunks
    assert_jws_bundle_match(jws, @key, @patient, @vax)
  end
end
