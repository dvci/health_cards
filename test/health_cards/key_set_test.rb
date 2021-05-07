# frozen_string_literal: true

require 'test_helper'

class KeySetTest < ActiveSupport::TestCase
  setup do
    @keys = [private_key, private_key]
  end

  ## Constructors

  test 'KeySet can be initialized without keys' do
    HealthCards::KeySet.new
  end

  test 'KeySet can be initialized with a single private key' do
    HealthCards::KeySet.new(@keys[0])
  end

  test 'KeySet can be initialized with a single public key' do
    HealthCards::KeySet.new(@keys[0].public_key)
  end

  test 'KeySet can be initialized with an array of private keys' do
    key_set = HealthCards::KeySet.new(@keys)
    assert_includes key_set, @keys[0]
    assert_includes key_set, @keys[1]
  end

  test 'KeySet can be initialized with an array of public keys' do
    key_set = HealthCards::KeySet.new(@keys.map(&:public_key))
    assert_includes key_set, @keys[0].public_key
    assert_includes key_set, @keys[1].public_key
  end

  test 'KeySet can be created from an JWKS' do
    jwks = HealthCards::KeySet.new(@keys).to_jwk
    key_set = HealthCards::KeySet.from_jwks(jwks)
    assert_includes key_set, @keys[0]
    assert_includes key_set, @keys[1]
  end

  ## Adding and Removing Keys

  test 'A single private can be added to an existing KeySet' do
    key_set = HealthCards::KeySet.new
    assert_not_includes key_set, @keys[0]
    key_set.add_keys @keys[0]
    assert_includes key_set, @keys[0]
  end

  test 'A single private key can be removed from an existing KeySet' do
    key_set = HealthCards::KeySet.new(@keys[0])
    assert_includes key_set, @keys[0]
    key_set.remove_keys @keys[0]
    assert_not_includes key_set, @keys[0]
  end

  test 'An array of private keys can be added to an existing KeySet' do
    key_set = HealthCards::KeySet.new
    assert_not_includes key_set, @keys[0]
    assert_not_includes key_set, @keys[1]
    key_set.add_keys @keys
    assert_includes key_set, @keys[0]
    assert_includes key_set, @keys[1]
  end

  test 'An array of private keys can be removed from an existing KeySet' do
    key_set = HealthCards::KeySet.new(@keys)
    assert_includes key_set, @keys[0]
    assert_includes key_set, @keys[1]
    key_set.remove_keys @keys
    assert_not_includes key_set, @keys[0]
    assert_not_includes key_set, @keys[1]
  end

  test 'A KeySet can be added to an existing KeySet' do
    diff_keys = [private_key, private_key]
    key_set2 = HealthCards::KeySet.new(diff_keys)

    key_set = HealthCards::KeySet.new(@keys)
    assert_not_includes key_set, diff_keys[0]
    assert_not_includes key_set, diff_keys[1]
    key_set.add_keys(key_set2)
    assert_includes key_set, diff_keys[0]
    assert_includes key_set, diff_keys[1]
  end

  test 'A KeySet can be removed from an existing KeySet' do
    key_set2 = HealthCards::KeySet.new(@keys)

    key_set = HealthCards::KeySet.new(@keys)
    assert_includes key_set, @keys[0]
    assert_includes key_set, @keys[1]
    key_set.remove_keys(key_set2)
    assert_not_includes key_set, @keys[0]
    assert_not_includes key_set, @keys[1]
  end

  ## JWK Tests

  test 'exports to jwk' do
    key_set = HealthCards::KeySet.new(@keys)
    jwks = JSON.parse(key_set.to_jwk)
    assert_equal 2, jwks['keys'].length
    jwks['keys'].each do |entry|
      assert_equal 'sig', entry['use']
      assert_equal 'ES256', entry['alg']
    end
  end
end
