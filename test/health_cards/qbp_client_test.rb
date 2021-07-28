# frozen_string_literal: true

require 'test_helper'
require 'health_cards/qbp_client'

class QBPClientTest < ActiveSupport::TestCase
  setup do
    @complete_patient = { patient_list: { id: 'J19X5',
                                          assigning_authority: 'AIRA-TEST',
                                          identifier_type_code: 'MR' },
                          patient_name: { family_name: 'WeilAIRA',
                                          given_name: 'BethesdaAIRA',
                                          second_or_further_names: 'Delvene',
                                          suffix: '' },
                          mothers_maiden_name: { family_name: 'WeilAIRA',
                                                 given_name: 'BethesdaAIRA',
                                                 name_type_code: 'M' },
                          patient_dob: '20170610',
                          admin_sex: 'F',
                          address: { street: '1113 Wollands Kroon Ave',
                                     city: 'Hamburg',
                                     state: 'MI',
                                     zip: '48139',
                                     address_type: 'P' },
                          phone: { area_code: '810',
                                   local_number: '2499010' } }

    WebMock.allow_net_connect!
  end

  def teardown
    WebMock.disable_net_connect!
  end

  # General Functionality Tests

  test 'query() method successfully returns an HL7 Message' do
    v2_response_body = HealthCards::QBPClient.query({})
    assert_instance_of(HL7::Message, v2_response_body)
  end

  test 'translate_to_fhir() method successfully returns a stringified JSON object' do
    v2_response_body = HealthCards::QBPClient.query({})
    fhir_response_body = HealthCards::QBPClient.translate_to_fhir(v2_response_body)
    parsed_fhir_response = begin
      JSON.parse(fhir_response_body)
    rescue StandardError
      nil
    end
    assert_not_nil(parsed_fhir_response)
  end

  test 'raises error if inputted sandbox credentials are incorrectly formatted' do
    user_sandbox_credentials = { username: 'test_user', password: 'test_password', facilityID: 'test_facilityID' }
    missing_credential = user_sandbox_credentials.except(:password)
    assert_raises HealthCards::InvalidSandboxCredentialsError do
      HealthCards::QBPClient.query({}, missing_credential)
    end

    non_string_credential = user_sandbox_credentials
    non_string_credential[:password] = 1
    assert_raises HealthCards::InvalidSandboxCredentialsError do
      HealthCards::QBPClient.query({}, non_string_credential)
    end
  end

  # Client Connectivity Tests

  test 'Connectivity Test Works (Successfully connected to IIS Sandbox endpoint)' do
    service_def = 'lib/assets/service.wsdl'
    client = Savon.client(wsdl: service_def,
                          endpoint: 'http://localhost:8081/iis-sandbox/soap',
                          pretty_print_xml: true)
    assert_nothing_raised do
      HealthCards::QBPClient.check_client_connectivity(client) if client.operations.include?(:connectivity_test)
    end
  end

  # SOAP Faults

  test 'SOAP FAULT: SecurityFault - bad credentials' do
    user_sandbox_credentials = { username: 'mitre', password: 'bad_password', facilityID: 'MITRE Healthcare' }
    assert_raises HealthCards::SOAPError do
      HealthCards::QBPClient.query({}, user_sandbox_credentials)
    end
  end

  test 'SOAP FAULT: Unknown fault - generic error' do
    # NOTE: This functionality may be updated within the IIS Sandbox, according to recent conversation with Nathan
    # Currently, this throws the same exception as the above "Security Fault"
    user_sandbox_credentials = { username: 'NPE', password: 'NPE', facilityID: 'MITRE Healthcare' }
    assert_raises HealthCards::SOAPError do
      HealthCards::QBPClient.query({}, user_sandbox_credentials)
    end
  end

  # Response Error Cases
  #   NOTE: We currently use a locally downloaded version of the correctly implemented WSDL file,
  #   so we will not have to worry about poorly formatted responses for our use case

  # Check Response Statuses

  test 'Status of OK - "Data found, no errors" is returned for valid patient with all fields specified' do
    response = HealthCards::QBPClient.query(@complete_patient)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:OK, status)
  end

  test 'Status of OK - "Data found, no errors" is returned for valid patient with minimum fields specified' do
    minimal_data_patient = @complete_patient.slice(:patient_name, :patient_dob)
    minimal_data_patient[:patient_name] = minimal_data_patient[:patient_name].slice(:family_name, :given_name)
    response = HealthCards::QBPClient.query(minimal_data_patient)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:OK, status)
  end

  test 'Patient not in sandbox returns a response status of NF - "No data found, no errors"' do
    missing_patient =  { patient_name: { family_name: 'Not In Sandbox', given_name: 'Patient' },
                         patient_dob: '20200101' }
    response = HealthCards::QBPClient.query(missing_patient)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:NF, status)
  end

  test 'Patient without required data fields returns a response status of AE - "Application Error"' do
    response = HealthCards::QBPClient.query({})
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:AE, status)
  end

  test 'Unspecific query returns Z31 profile indicating that one or more low confidence matches are found' do
    duplicate_patient = @complete_patient.deep_dup
    # NOTE: This is a specialized query built into the sandbox that allows for the return of a Z31 multi-match profile
    # I was unable to trigger this response manually by uploading similar patients into the sandbox.
    duplicate_patient[:patient_name][:second_or_further_names] = 'Multi'
    response = HealthCards::QBPClient.query(duplicate_patient)
    profile = response[:MSH][20]
    assert_equal('Z31^CDCPHINVS', profile)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:TM, status)
  end

  # V2 to FHIR Translation Tests

  test 'Valid HL7 V2 Complete Immunization History Response will return a FHIR Bundle from the HL7 to V2 Translator' do
    response = File.open('test/fixtures/files/RSP_valid.hl7').readlines
    v2_response = HL7::Message.new(response)
    fhir_response = HealthCards::QBPClient.translate_to_fhir(v2_response)
    fhir_response_hash = JSON.parse(fhir_response)
    assert_equal('Bundle', fhir_response_hash['resourceType'])
  end

  test 'Non-Patient HL7 V2 Response will return an error message from the HL7 to V2 Translator' do
    response = File.open('test/fixtures/files/RSP_error.hl7').readlines
    v2_response = HL7::Message.new(response)
    fhir_response = HealthCards::QBPClient.translate_to_fhir(v2_response)
    fhir_response_hash = JSON.parse(fhir_response)
    assert_not_nil(fhir_response_hash['errors'])
  end

  # # WARNING: Running tests with this test uncommented could change sandbox data and cause other tests to fail
  # # Temporary Test to upload a patient
  # test 'Uploading a patient' do
  #   HealthCards::QBPClient.upload_patient() #Enter VXU Upload fixture path parameter here
  # end
end
