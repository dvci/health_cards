# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: 'a')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @key = rails_public_key
  end

  test 'get health card download' do
    get(patient_health_card_path(@patient, format: 'smart-health-card'))

    json = JSON.parse(response.body)
    vc = json['verifiableCredential']

    assert_not_nil vc
    assert_equal 1, vc.size

    card = nil

    assert_nothing_raised do
      card = HealthCards::HealthCard.from_jws(vc.first, public_key: @key)
    end

    entries = card.bundle.entry

    patient = entries[0].resource
    assert patient.valid?
    assert_equal @patient.given, patient.name[0].given[0]

    imm = entries[1].resource

    # Deactivated until spec or FHIR validator is updated
    # assert imm.valid?

    assert_equal @vax.code, imm.vaccineCode.coding[0].code

    assert_response :success
  end

  test 'get chunks for QR code generation' do
    get(chunks_patient_health_card_url(@patient))
    assert_response :success

    chunks = JSON.parse(response.body)
    # Check that each string in the array is a numeric string
    chunks.each do |s|
      assert_empty(s.scan(/\D/))
    end
  end
end
