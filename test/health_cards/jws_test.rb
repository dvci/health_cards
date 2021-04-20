# frozen_string_literal: true

require 'test_helper'

class JWSTest < ActiveSupport::TestCase
  setup do
    @payload = 'foo'
    @private_key = private_key
  end

  ## Constructor

  test 'JWS can be created from string payload' do
    HealthCards::JWS.new(payload: @payload)
  end
end
