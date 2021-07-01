# frozen_string_literal: true

require 'test_helper'
require 'health_cards/qbp_client'

class QBPClientTest < ActiveSupport::TestCase
  setup do
    # Do setup stuff
  end

  test 'does it run' do
    WebMock.allow_net_connect!
    v2_response_body = HealthCards::QBPClient.query(nil)
    fhir_response_body = HealthCards::QBPClient.tranlate(v2_response_body)
    WebMock.disable_net_connect!
  end

  test 'raises error if sandbox credentials are incorrectly formatted' do
    user_sandbox_credentials = { username: "test_user", password: "test_password", facilityID: "test_facilityID" }

    missing_credential = user_sandbox_credentials.except(:password)
    assert_raises HealthCards::InvalidSandboxCredentialsError do
      response = HealthCards::QBPClient.query(nil, missing_credential)
    end

    non_string_credential = user_sandbox_credentials
    non_string_credential[:password] = 1
    assert_raises HealthCards::InvalidSandboxCredentialsError do
      response = HealthCards::QBPClient.query(nil, non_string_credential)
    end

  end


end

# Connectivity Test Works (Connect to endpoint)

# MSH Propertly Added
    # Time is a time
    # UID is a number
# QPD patient info properly added
    # Check that each element matches a string (i.e.  Mother's maiden name =  ^^name^^
# Check that all 3 required segments are there
# Checdkd that message is properly formed hl7 v2 message

# Check to see that response is received
# Response is properly formed as an HL7 message

# Connection to V2 to fhir works
# Receive back a FHIR Resoruce

# Check each type of Error 
  # Proper message returns Z32
  # Need to Refine - Z31
  # Error - Z33
  
# Checks for Proper Response
  # Check if each V2 Segment is there in the response
  # There should be no errors
  # There should be a vaccine
  # QAK should have proper query response status (OK) - Also should have proper status for errors as well
  # Same QPD should be returned

# Check that message is ackn olwedged (MSA1 = AA)
# Check that there are not query errors (QAK2 != AE or AR)
# Add ToDo for handling PD and TM
# Check that Data is found, not found (QAK2 = OF, NF)