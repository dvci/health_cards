# frozen_string_literal: true

require 'test_helper'
require 'health_cards/qbp_client'

class QBPClientTest < ActiveSupport::TestCase
  setup do
    @patient_hash = {:patient_list=>{:id=>'J19X5',
                                      :assigning_authority=>'AIRA-TEST',
                                      :identifier_type_code=>'MR'
                                      },
                      :patient_name=>{:family_name=>'WeilAIRA',
                                      :given_name=>'BethesdaAIRA',                       
                                      :second_or_further_names=>'Delvene',
                                      :suffix=>''},
                      :mothers_maiden_name=>{:family_name=>'WeilAIRA',
                                            :given_name=>'BethesdaAIRA',
                                            :name_type_code=>'M'},
                      :patient_dob=>"20170610",
                      :admin_sex=>"F",
                      :address=>{:street=>'1113 Wollands Kroon Ave',
                                 :city=>'Hamburg',
                                 :state=>'MI',
                                 :zip=>'48139',
                                 :address_type=>'P'
                                 },
                      :phone=>{:area_code=>'810',
                               :local_number=>'2499010'}
    }
                      
    # patient_info_minimal = {:patient_name=>{:given=>"Eleni", :family=>"Labadie", :second=>"", :suffix=>""}, :patient_dob=>"19802908", :patient_list=>{:assigning_authority=>"", :identifier_type_code=>"", :id=>""}, :mother_maiden_name=>{:family=>"", :given=>""}, :sex=>"", :address=>{:city=>"", :state=>"", :zip=>"", :street=>", "}}
    # patient_info_verbose = {:patient_name=>{:given=>"John", :family=>"Smith", :second=>"S", :suffix=>"Jr"}, :patient_dob=>"19802908", :patient_list=>{:assigning_authority=>"Dont", :identifier_type_code=>"Know", :id=>"I"}, :mother_maiden_name=>{:family=>"Hill", :given=>"Jill"}, :sex=>"male", :address=>{:city=>"Bedford", :state=>"MA", :zip=>"54321", :street=>"1111 2nd Ave, Apt 3D"}, :phone=>{:area_code=>"800", :local_number=>"7654321"}}

    WebMock.allow_net_connect!
  end

  def teardown
    WebMock.disable_net_connect!
  end

  # test 'does it run' do
  #   v2_response_body = HealthCards::QBPClient.query(nil)
  #   fhir_response_body = HealthCards::QBPClient.tranlate(v2_response_body)
  # end

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

  test 'patient parameters are properly converted to HL7 V2 elements' do
    v2_response_body = HealthCards::QBPClient.query(@patient_hash)
    fhir_response_body = HealthCards::QBPClient.tranlate(v2_response_body)
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