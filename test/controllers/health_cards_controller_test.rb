# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @vax = Vaccine.create(code: '207')
    @imm = @patient.immunizations.create(vaccine: @vax, occurrence: Time.zone.today)
    @key = rails_public_key
    @fhir_url = issue_vc_url(@patient, format: :fhir_json)
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

  test 'create health card PDF' do
    post(patient_health_card_path(@patient, format: 'pdf'))
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

  test 'issue smart card' do
    param = FHIR::Parameters::Parameter.new(name: 'credentialType',
                                            valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, as: :json)

    assert response['Access-Control-Allow-Origin'], '*'

    output = FHIR.from_contents(response.body)

    assert output.is_a?(FHIR::Parameters)
    cred = output.parameter.find { |par| par.name == 'verifiableCredential' }

    jws = HealthCards::JWS.from_jws(cred.valueString)
    jws.public_key = rails_issuer.key.public_key
    assert jws.verify

    # TODO: The spec currently requires references that are invalid
    # according to the FHIR validator
    # Turn this back on when we can update the code/validator
    # assert imm.valid?, imm.validate

    card = HealthCards::COVIDHealthCard.from_payload(jws.payload)
    assert card.bundle.entry[0].resource.is_a?(FHIR::Patient)
    assert card.bundle.entry[1].resource.is_a?(FHIR::Immunization)
  end

  test 'empty parameter' do
    post(@fhir_url, params: {}, as: :json)

    output = FHIR.from_contents(response.body)
    assert output.is_a?(FHIR::OperationOutcome)
    assert output.valid?
  end

  test 'invalid parameter' do
    param = FHIR::Parameters::Parameter.new(valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])
    post(@fhir_url, params: params.to_hash, as: :json)

    output = FHIR.from_contents(response.body)
    assert output.is_a?(FHIR::OperationOutcome)
    assert output.valid?
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
