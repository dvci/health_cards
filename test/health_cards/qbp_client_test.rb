# frozen_string_literal: true

require 'test_helper'
require 'health_cards/qbp_client'

class QBPClientTest < ActiveSupport::TestCase
  setup do
    @patient_hash = { patient_list: { id: 'J19X5',
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

    # TODO: Create These Other ones using functions
    @empty_hash = {
      patient_list: { id: '',
                      assigning_authority: '',
                      identifier_type_code: '' },
      patient_name: { family_name: 'Not In Sandbox',
                      given_name: 'Patient',
                      second_or_further_names: '',
                      suffix: '' },
      mothers_maiden_name: { family_name: '',
                             given_name: '',
                             name_type_code: '' },
      patient_dob: '20200101',
      admin_sex: '',
      address: { street: '',
                 city: '',
                 state: '',
                 zip: '',
                 address_type: '' },
      phone: { area_code: '81',
               local_number: '' }
    }

    @no_data = {
      patient_list: { id: '',
                      assigning_authority: '',
                      identifier_type_code: '' },
      patient_name: { family_name: '',
                      given_name: '',
                      second_or_further_names: '',
                      suffix: '' },
      mothers_maiden_name: { family_name: '',
                             given_name: '',
                             name_type_code: '' },
      patient_dob: '',
      admin_sex: '',
      address: { street: '',
                 city: '',
                 state: '',
                 zip: '',
                 address_type: '' },
      phone: { area_code: '',
               local_number: '' }
    }

    # TODO: Test with minimal and verbose data

    WebMock.allow_net_connect!
    # TODO: If patient doesn't exist, upload him to the sandbox
  end

  def teardown
    WebMock.disable_net_connect!
  end


  # General Functionality Tests

  test 'query() method successfully returns an HL7 Message' do
    v2_response_body = HealthCards::QBPClient.query(@no_data)
    assert_instance_of(HL7::Message, v2_response_body)
  end

  test 'translate() method successfully returns a JSON object' do
    v2_response_body = HealthCards::QBPClient.query(@no_data)
    fhir_response_body = HealthCards::QBPClient.translate(v2_response_body)
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
      HealthCards::QBPClient.query(nil, missing_credential)
    end

    non_string_credential = user_sandbox_credentials
    non_string_credential[:password] = 1
    assert_raises HealthCards::InvalidSandboxCredentialsError do
      HealthCards::QBPClient.query(nil, non_string_credential)
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

  test 'SecurityFault - bad credentials' do
    user_sandbox_credentials = { username: 'test_user', password: 'test_password', facilityID: 'test_facilityID' }
    HealthCards::QBPClient.query(@patient_hash, user_sandbox_credentials)
  end



  # Check Response Status
  test 'Patient in sandbox returns a response status of OK - "Data found, no errors (this is the default)"' do
    response = HealthCards::QBPClient.query(@patient_hash)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:OK, status)
  end

  test 'Patient not in sandbox returns a response status of NF - "Data found, no errors (this is the default)"' do
    response = HealthCards::QBPClient.query(@empty_hash)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:NF, status)
  end

  test 'Patient without required data fields returns a response status of AE - "Applicaiton Error"' do
    response = HealthCards::QBPClient.query(@no_data)
    status = HealthCards::QBPClient.get_response_status(response)
    assert_equal(:AE, status)
  end

  ## TODO: Add 2 similar patients to test :TM



  # Temporary Test to log things
  test 'patient parameters are properly converted to HL7 V2 elements' do
    v2_response_body = HealthCards::QBPClient.query(@patient_hash)

    puts 'RESPONSE:'
    puts(v2_response_body) # Printing response for testing purposes
    fhir_response_body = HealthCards::QBPClient.translate(v2_response_body)

    puts ''
    puts 'FHIR:'
    puts fhir_response_body # Printing response for testing purposes
  end

  # # Temporary Test to upload a patient
  # test 'Uploading a patient' do
  #   HealthCards::QBPClient.upload_patient("lib/assets/vxu_2_2.hl7")
  # end

end




# NOTES / FUTURE TESTS

# MSH Propertly Added
#   Time is a time
#   UID is a number
# QPD patient info properly added
#   Check that each element matches a string (i.e.  Mother's maiden name =  ^^name^^
# Check that all 3 required segments are there
# Checdkd that message is properly formed hl7 v2 message

# Check to see that response is received
# Response is properly formed as an HL7 message

# Connection to V2 to fhir works
# Receive back a FHIR Resoruce

# Check each type of Error
#   Proper message returns Z32
#   Need to Refine - Z31
#   Error - Z33

# Checks for Proper Response
#   Check if each V2 Segment is there in the response
#   There should be no errors
#   There should be a vaccine
#   QAK should have proper query response status (OK) - Also should have proper status for errors as well
#   Same QPD should be returned

# Check that message is ackn olwedged (MSA1 = AA)
# Check that there are not query errors (QAK2 != AE or AR)
# Add ToDo for handling PD and TM
# Check that Data is found, not found (QAK2 = OF, NF)