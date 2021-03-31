# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: 'a')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @issuer = Rails.application.config.issuer
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

    # TODO The spec currently requires references that are invalid
    # and violate the FHIR validator. Turn this back on when we can
    # update the code
    # assert imm.valid?, imm.validate

    assert_equal @vax.code, imm.vaccineCode.coding[0].code

    assert_response :success
  end

  test 'issue smart card' do
    param = FHIR::Parameters.new(parameter: [FHIR::Parameters::Parameter.new(name: 'credentialType', valueUri: 'https://smarthealth.cards#covid19')])
    url = issue_vc_url(@patient, format: :fhir_json)
    
    post(url, params: param.to_hash, as: :json)

    output = FHIR.from_contents(response.body)
    cred = output.parameter.find { |param| param.name = 'verifiableCredential'}
    assert_not_nil cred
    json = nil
    assert_nothing_raised do
      json = JSON::JWT.decode(cred.valueString, @issuer.public_key)
    end

    assert_not json.nil?

    entries = json.dig('credentialSubject', 'fhirBundle', 'entry')

    assert_not entries.nil?
  end

end
