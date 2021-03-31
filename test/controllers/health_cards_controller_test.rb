# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: 'a')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @key = rails_public_key
    @fhir_url = issue_vc_url(@patient, format: :fhir_json)
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

  test 'get chunks for QR code generation' do
    get(chunks_patient_health_card_url(@patient))
    assert_response :success

    chunks = JSON.parse(response.body)
    jws = HealthCards::Chunking.assemble_jws chunks
    assert_jws_bundle_match(jws, @key, @patient, @vax)
  end

  test 'issue smart card' do
    param = FHIR::Parameters::Parameter.new(name: 'credentialType',
                                            valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, as: :json)

    output = FHIR.from_contents(response.body)

    assert output.is_a?(FHIR::Parameters)
    cred = output.parameter.find { |par| par.name == 'verifiableCredential' }

    jws = HealthCards::JWS.from_jws(cred.valueString)
    jws.public_key = rails_issuer.key.public_key
    assert jws.verify
    # TODO: The spec currently requires references that are invalid
    # and violate the FHIR validator. Turn this back on when we can
    # update the code
    # assert imm.valid?, imm.validate

    card = HealthCards::COVIDHealthCard.from_payload(jws.payload)
    assert card.bundle.entry[0].resource.is_a?(FHIR::Patient)
    assert card.bundle.entry[1].resource.is_a?(FHIR::Immunization)
  end

  test 'empty parameter' do
    post(@fhir_url, params: {}, as: :json)

    output = FHIR.from_contents(response.body)
    assert output.is_a?(FHIR::OperationOutcome)
  end

  test 'invalid parameter' do
    param = FHIR::Parameters::Parameter.new(valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])
    post(@fhir_url, params: params.to_hash, as: :json)

    output = FHIR.from_contents(response.body)
    assert output.is_a?(FHIR::OperationOutcome)
  end

  test 'unsupported card type' do
    param = FHIR::Parameters::Parameter.new(name: 'credentialType',
                                            valueUri: 'https://smarthealth.cards#not-valid-type')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, as: :json)

    output = FHIR.from_contents(response.body)
    assert output.is_a?(FHIR::Parameters)
    assert_empty output.parameter
  end
end
