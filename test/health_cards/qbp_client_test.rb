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
