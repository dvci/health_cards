# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: 'a')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @issuer = Rails.application.config.issuer
    @covid_health_card = CovidHealthCard.new(@patient, 'url')
  end

  test 'get health card download' do
    get(patient_health_card_path(@patient, format: 'smart-health-card'))
    json = JSON.parse(response.body)
    vc = json['verifiableCredential']

    assert_not_nil vc
    assert_equal 1, vc.size

    json = nil
    assert_nothing_raised do
      json = JSON::JWT.decode(vc.first, @issuer.public_key)
    end

    assert_not json.nil?

    entries = json.dig('credentialSubject', 'fhirBundle', 'entry')

    assert_not entries.nil?

    patient = FHIR.from_contents(entries[0]['resource'].to_json)
    assert patient.valid?
    assert_equal @patient.given, patient.name[0].given[0]

    imm = FHIR.from_contents(entries[1]['resource'].to_json)

    assert imm.valid?

    assert_equal @vax.code, imm.vaccineCode.coding[0].code

    assert_response :success
  end

  test 'get chunks for QR code generation' do
    get(chunks_patient_health_card_url(@patient))
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
  end
end
