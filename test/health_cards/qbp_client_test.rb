# frozen_string_literal: true

require 'test_helper'
require 'health_cards/qbp_client'

class QBPClientTest < ActiveSupport::TestCase
  test 'does it run' do
    WebMock.allow_net_connect!
    fhir_response_body = HealthCards::QBPClient.query()
    WebMock.disable_net_connect!
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

