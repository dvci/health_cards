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
    get(patient_health_card_path(@patient, format: 'pdf'))
    assert_response :success
  end

  test 'should show health card' do
    get(patient_health_card_url(@patient, format: :html))
    assert_response :success
  end

  test 'upload file' do
    stub_request(:get, 'https://smarthealth.cards/examples/issuer/.well-known/jwks.json').to_return(body: '{"keys":[]}')
    file = fixture_file_upload('test/fixtures/files/example-00-e-file.smart-health-card')
    post(upload_health_cards_path, params: { health_card: file })
    assert_response :success
  end

  test 'upload file with no keys found' do
    stub_request(:get, 'https://smarthealth.cards/examples/issuer/.well-known/jwks.json').to_return(body: nil,
                                                                                                    status: 404)
    file = fixture_file_upload('test/fixtures/files/example-00-e-file.smart-health-card')
    post(upload_health_cards_path, params: { health_card: file })
    assert_response :success
  end

  test 'upload file with keys timeout' do
    stub_request(:get, 'https://smarthealth.cards/examples/issuer/.well-known/jwks.json').to_timeout
    file = fixture_file_upload('test/fixtures/files/example-00-e-file.smart-health-card')
    post(upload_health_cards_path, params: { health_card: file })
    assert_response :success
  end

  test 'issue smart card' do
    param = FHIR::Parameters::Parameter.new(name: 'credentialType',
                                            valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, headers: { 'Origin' => 'http://example.com' }, as: :json)

    assert response['Access-Control-Allow-Origin'], '*'

    output = assert_fhir(response.body, type: FHIR::Parameters)

    cred = output.parameter.find { |par| par.name == 'verifiableCredential' }

    jws = HealthCards::JWS.from_jws(cred.valueString)
    jws.public_key = rails_issuer.key.public_key
    assert jws.verify

    # TODO: The spec currently requires references that are invalid
    # according to the FHIR validator
    # Turn this back on when we can update the code/validator
    # assert imm.valid?, imm.validate

    card = HealthCards::COVIDPayload.from_payload(jws.payload)
    assert card.bundle.entry[0].resource.is_a?(FHIR::Patient)
    assert card.bundle.entry[1].resource.is_a?(FHIR::Immunization)
  end

  test 'should return OperationOutcome when no patient exists for $issue endpoint' do
    post issue_vc_path(patient_id: 1234, format: :fhir_json)
    assert_operation_outcome(response)
  end

  test 'should return OperationOutcome when no patient exists for $issue endpoint with accept header' do
    post issue_vc_path(patient_id: 1234), headers: { Accept: 'application/fhir+json' }
    assert_operation_outcome(response)
  end

  test 'no FHIR::Parameters' do
    post(@fhir_url, params: {}, as: :json)

    assert_operation_outcome(response, response_code: :bad_request)
  end

  test 'invalid FHIR::Parameters' do
    param = FHIR::Parameters::Parameter.new(valueUri: 'https://smarthealth.cards#covid19')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, as: :json)

    assert_operation_outcome(response, response_code: :bad_request)
  end

  test 'unsupported card type' do
    param = FHIR::Parameters::Parameter.new(name: 'credentialType',
                                            valueUri: 'https://smarthealth.cards#not-valid-type')
    params = FHIR::Parameters.new(parameter: [param])

    post(@fhir_url, params: params.to_hash, as: :json)

    output = assert_fhir(response.body, type: FHIR::Parameters)
    assert_empty output.parameter
  end
end
