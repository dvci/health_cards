# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class KeyTest < ActiveSupport::TestCase
  setup do
    @key_path = rails_key_path
    @key = HealthCards::PrivateKey.load_from_or_create_from_file(@key_path)
    @test_jwk = {
      kty: "EC",
      kid: "3Kfdg-XwP-7gXyywtUfUADwBumDOPKMQx-iELL11W9s",
      use: "sig",
      alg: "ES256",
      crv: "P-256",
      x: "11XvRWy1I2S0EyJlyf_bWfw_TQ5CJJNLw78bHXNxcgw",
      y: "eZXwxvO1hvCY0KucrPfKo7yAyMT6Ajc3N7OkAB6VYy8"
    }
  end

  teardown do
    cleanup_keys
  end

  test 'creates keys' do
    assert_path_exists(@key_path)
  end

  test 'kid calculation is correct' do
    jwk = HealthCards::Key.from_jwk(@test_jwk)
    assert_equal jwk.kid, @test_jwk[:kid]
  end

  test 'exports to jwk' do
    jwk = @key.public_key.to_jwk

    assert_not_nil jwk[:x]
    assert_not_nil jwk[:y]
    assert_nil jwk[:d]

    assert_equal 'sig', jwk[:use]
    assert_equal 'ES256', jwk[:alg]
  end

  test 'Create key from jwk containing the private key' do
    jwk = @key.to_jwk
    jwk_key = HealthCards::Key.from_jwk(jwk)

    assert jwk_key.is_a? HealthCards::PrivateKey

    assert_not_nil jwk[:x]
    assert_not_nil jwk[:y]
    assert_not_nil jwk[:d]

    assert_equal @key.kid, jwk_key.kid

    new_jwk = jwk_key.to_jwk
    assert_equal jwk[:x], new_jwk[:x]
    assert_equal jwk[:y], new_jwk[:y]
    assert_equal jwk[:d], new_jwk[:d]
  end

  test 'Create key from jwk containing the public key' do
    jwk = @key.public_key.to_jwk
    jwk_key = HealthCards::Key.from_jwk(jwk)

    assert jwk_key.is_a? HealthCards::PublicKey

    assert_not_nil jwk[:x]
    assert_not_nil jwk[:y]
    assert_nil jwk[:d]

    assert_equal @key.kid, jwk_key.kid

    new_jwk = jwk_key.to_jwk
    assert_equal jwk[:x], new_jwk[:x]
    assert_equal jwk[:y], new_jwk[:y]
  end

  test 'public coordinates doesn\'t include d' do
    pk = @key.public_key
    assert_nil pk.public_coordinates[:d]
    assert_equal @key.public_coordinates, pk.coordinates
  end

  test 'Use existing keys if they exist' do
    original_jwks = @key.public_key.to_json

    new_jwks = HealthCards::PrivateKey.load_from_or_create_from_file(@key_path).public_key.to_json

    assert_equal original_jwks, new_jwks
  end

  test 'verify payload' do
    payload = 'foo'
    sigg = @key.sign('foo')
    assert @key.public_key.verify(payload, sigg)
  end
end
