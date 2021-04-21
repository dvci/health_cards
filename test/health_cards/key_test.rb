# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class KeyTest < ActiveSupport::TestCase
  setup do
    @key_path = rails_key_path
    @key = HealthCards::PrivateKey.load_for_create_from_file(@key_path)
  end

  teardown do
    cleanup_keys
  end

  test 'creates keys' do
    assert_path_exists(@key_path)
  end

  test 'exports to jwk' do
    jwk = @key.public_key.to_jwk

    assert_not_nil jwk[:x]
    assert_not_nil jwk[:x]
    assert_nil jwk[:d]

    assert_equal 'sig', jwk[:use]
    assert_equal 'ES256', jwk[:alg]
  end

  test 'Use existing keys if they exist' do
    original_jwks = @key.public_key.to_json

    new_jwks = HealthCards::PrivateKey.load_for_create_from_file(@key_path).public_key.to_json

    assert_equal original_jwks, new_jwks
  end

  test 'verify payload' do
    payload = 'foo'
    sigg = @key.sign('foo')
    assert @key.public_key.verify(payload, sigg)
  end
end
