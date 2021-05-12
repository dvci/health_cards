# frozen_string_literal: true

require 'test_helper'

class VerifierTest < ActiveSupport::TestCase
  setup do
    @private_key = private_key
    @public_key = @private_key.public_key
    @verifier = HealthCards::Verifier.new(keys: rails_public_key)
    @jws = rails_issuer.issue_jws(bundle_payload)
  end

  ## Constructors

  test 'Create a new Verifier with a public key' do
    HealthCards::Verifier.new(keys: @public_key)
  end

  test 'Create a new Verifier with a private key' do
    HealthCards::Verifier.new(keys: @private_key)
  end

  test 'Create a new Verifier with a KeySet' do
    key_set = HealthCards::KeySet.new(@public_key)
    HealthCards::Verifier.new(keys: key_set)
  end

  ## Key Export

  test 'Verifier exports public keys as JWK' do
    verifier = HealthCards::Verifier.new(keys: @private_key)
    key_set = verifier.keys
    assert key_set.is_a? HealthCards::KeySet
  end

  ## Adding and Removing Keys

  test 'Verifier allows public keys to be added' do
    verifier = HealthCards::Verifier.new
    assert_empty verifier.keys
    verifier.add_keys @public_key
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @public_key
  end

  test 'Verifier allows public keys to be removed' do
    verifier = HealthCards::Verifier.new(keys: @public_key)
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @public_key
    verifier.remove_keys @public_key
    assert_empty verifier.keys
  end

  test 'Verifier allows private keys to be added' do
    verifier = HealthCards::Verifier.new
    assert_empty verifier.keys
    verifier.add_keys @private_key
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @private_key
  end

  test 'Verifier allows private keys to be removed' do
    verifier = HealthCards::Verifier.new(keys: @private_key)
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @private_key
    verifier.remove_keys @private_key
    assert_empty verifier.keys
  end

  ## Verification

  test 'Verifier can verify JWS object' do
    assert @verifier.verify(@jws)
  end

  test 'Verifier can verify JWS String' do
    assert @verifier.verify(@jws.to_s)
  end

  test 'Verifier doesn\'t verify none JWS-able object' do
    assert_raises ArgumentError do
      @verifier.verify(OpenStruct.new(foo: 'bar'))
    end
  end

  test 'Verifier throws exception when attempting to verify health card without an accessible public key' do
    stub_request(:get, /jwks.json/).to_return(body: HealthCards::KeySet.new(@public_key).to_jwk)
    verifier = HealthCards::Verifier.new
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @jws
    end

    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @jws
    end
  end

  test 'Verifier can verify JWS when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @verifier.keys.to_jwk)
    verifier = HealthCards::Verifier.new
    assert verifier.verify(@jws)
  end

  ### Verification Class Methods
  test 'Verifier class throws exception when attempting to verify health card without an accessible public key' do
    stub_request(:get, /jwks.json/).to_return(body: HealthCards::KeySet.new(@public_key).to_jwk)

    verifier = HealthCards::Verifier
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @jws
    end
  end

  test 'Verifier class can verify health cards when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @verifier.keys.to_jwk)
    verifier = HealthCards::Verifier
    assert verifier.verify(@jws)
  end

  ## Key Resolution

  test 'Verifier key resolution is active by default' do
    assert HealthCards::Verifier.new.resolve_keys?
  end

  test 'Verifier key resolution can be disabled' do
    verifier = HealthCards::Verifier.new
    assert verifier.resolve_keys?
    verifier.resolve_keys = false
    assert_not verifier.resolve_keys?
    verifier.resolve_keys = true
  end

  test 'Verifier will not verify health cards when key is not resolvable' do
    stub_request(:get, /jwks.json/).to_return(status: 200, body: @verifier.keys.to_jwk)
    verifier = HealthCards::Verifier.new
    verifier.resolve_keys = false
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify(@jws)
    end
    verifier.resolve_keys = true
    assert verifier.verify(@jws)
  end

  test 'Verifier class will verify health cards when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(status: 200, body: @verifier.keys.to_jwk)
    verifier = HealthCards::Verifier
    assert verifier.verify(@jws)
  end
end
