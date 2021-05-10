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

  test 'changing keys causes signature update' do
    jws = HealthCards::JWS.new(payload: @payload, key: @private_key)
    old_sig = jws.signature
    jws.key = HealthCards::PrivateKey.generate_key
    new_sig = jws.signature
    assert_not_equal old_sig, new_sig
  end

  test 'changin payloads causes signature update' do
    jws = HealthCards::JWS.new(payload: @payload, key: @private_key)
    old_sig = jws.signature
    jws.payload = 'bar'
    new_sig = jws.signature
    assert_not_equal old_sig, new_sig
  end
end
