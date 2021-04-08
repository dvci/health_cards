# frozen_string_literal: true

require 'test_helper'

class Verifier < ActiveSupport::TestCase
  setup do
    @private_key = private_key
    @public_key = @private_key.public_key
    @health_card = HealthCards::HealthCard.new(payload: bundle_payload, private_key: @private_key)
  end

  ## Constructors

  test 'Create a new Verifier with a public key' do
    HealthCards::Verifier.new(key: @public_key)
  end

  test 'Create a new Verifier with a private key' do
    HealthCards::Verifier.new(key: @private_key)
  end

  ## Key Export

  test 'Verifier exports public keys as JWK' do
    verifier = HealthCards::Verifier.new(key: @private_key)
    key_set = verifier.keys
    assert key_set.is_a? HealthCards::JWK
  end

  ## Adding and Removing Keys

  test 'Verifier allows public keys to be added' do
    verifier = HealthCards::Verifier.new
    assert_empty verifier.keys
    verifier.add_key @public_key
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @public_key
  end

  test 'Verifier allows public keys to be removed' do
    verifier = HealthCards::Verifier.new(key: @public_key)
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @public_key
    verifier.remove_key @public_key
    assert_empty verifier.keys
  end

  test 'Verifier allows private keys to be added' do
    verifier = HealthCards::Verifier.new
    assert_empty verifier.keys
    verifier.add_key @private_key
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @private_key
  end

  test 'Verifier allows private keys to be removed' do
    verifier = HealthCards::Verifier.new(key:@private_key)
    assert_not_empty verifier.keys
    assert_includes verifier.keys, @private_key
    verifier.remove_key @private_key
    assert_empty verifier.keys
  end

  ## Verification

  test 'Verifier can verify health cards' do
    verifier = HealthCards::Verifier.new(public_key: @public_key)
    verifier.verify(@health_card)
  end

  test 'Verifier can verify JWS' do
    verifier = HealthCards::Verifier.new(public_key: @public_key)
    verifier.verify(@health_card.to_jws)
  end

  test 'Verifier throws exception when attempting to verify health card without an accessible public key' do
    verifier = HealthCards::Verifier.new
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card
    end

    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card.to_jws
    end
  end

  ### Verification Class Methods
  test 'Verifier class throws exception when attempting to verify health card without an accessible public key' do
    verifier = HealthCards::Verifier
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card
    end

    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card.to_jws
    end
  end

  test 'Verifier class can verify health cards when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier
    verifier.verify(@health_card)
  end

  test 'Verifier can verify JWS when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier.new
    verifier.verify(@health_card.to_jws)
  end

  ## Key Resolution

  test 'Verifier key resolution is active by default' do
    assert HealthCards::Verifier.new.globally_resolve_keys?
  end

  test 'Verifier key resolution can be disabled' do
    verifier = HealthCards::Verifier.new
    assert verifier.resolve_keys?
    verifier.resolve_keys = false
    assert_not verifier.resolve_keys?
    verifier.resolve_keys = true
  end

  test 'Verifier will not verify health cards when key is not resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier.new
    verifier.resolve_keys = false
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify(@health_card)
    end
    verifier.resolve_keys = true
    assert verifier.verify(@health_card)
  end

  test 'Verifier class key resolution is active by default' do
    assert HealthCards::Verifier.globally_resolve_keys?
  end

  test 'Verifier class key resolution can be disabled' do
    verifier = HealthCards::Verifier
    assert verifier.globally_resolve_keys?
    verifier.globally_resolve_keys = false
    assert_not verifier.globally_resolve_keys?
    verifier.globally_resolve_keys = true
  end

  test 'Verifier class will not verify health cards when key is not resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier
    verifier.globally_resolve_keys = false
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify(@health_card)
    end
    verifier.globally_resolve_keys = true
    assert verifier.verify(@health_card)
  end
end

