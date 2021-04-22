# frozen_string_literal: true

require 'test_helper'

class VerifierTest < ActiveSupport::TestCase
  setup do
    @private_key = private_key
    @public_key = @private_key.public_key
    @verifier = HealthCards::Verifier.new(keys: rails_public_key)
    @health_card = rails_issuer.create_health_card(bundle_payload)
  end

  ## Constructors

  test 'Create a new Verifier with a public key' do
    HealthCards::Verifier.new(keys: @public_key)
  end

  test 'Create a new Verifier with a private key' do
    HealthCards::Verifier.new(keys: @private_key)
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

  test 'Verifier can verify health cards' do
    assert @verifier.verify(@health_card)
  end

  test 'Verifier can verify JWS object' do
    assert @verifier.verify(@health_card.jws)
  end

  test 'Verifier can verify JWS String' do
    assert @verifier.verify(@health_card.jws.to_s)
  end

  test 'Verifier throws exception when attempting to verify health card without an accessible public key' do
    verifier = HealthCards::Verifier.new
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card
    end

    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card.jws
    end
  end

  ### Verification Class Methods
  test 'Verifier class throws exception when attempting to verify health card without an accessible public key' do
    skip('Need to update test so that health_card does not contain the public key it needs to verify')
    skip('Need to update Verifier::verify to accept JWS strings')
    verifier = HealthCards::Verifier
    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card
    end

    assert_raises HealthCards::MissingPublicKey do
      verifier.verify @health_card.jws
    end
  end

  test 'Verifier class can verify health cards when key is resolvable' do
    skip('Key resolution not implemented')
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier
    verifier.verify(@health_card)
  end

  test 'Verifier can verify JWS when key is resolvable' do
    skip('Key resolution not implemented')
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    verifier = HealthCards::Verifier.new
    verifier.verify(@health_card.jws)
  end

  ## Key Resolution

  test 'Verifier key resolution is active by default' do
    skip('Key resolution not implemented')
    assert HealthCards::Verifier.new.globally_resolve_keys?
  end

  test 'Verifier key resolution can be disabled' do
    skip('Key resolution not implemented')
    verifier = HealthCards::Verifier.new
    assert verifier.resolve_keys?
    verifier.resolve_keys = false
    assert_not verifier.resolve_keys?
    verifier.resolve_keys = true
  end

  test 'Verifier will not verify health cards when key is not resolvable' do
    skip('Key resolution not implemented')
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
    skip('Key resolution not implemented')
    assert HealthCards::Verifier.globally_resolve_keys?
  end

  test 'Verifier class key resolution can be disabled' do
    skip('Key resolution not implemented')
    verifier = HealthCards::Verifier
    assert verifier.globally_resolve_keys?
    verifier.globally_resolve_keys = false
    assert_not verifier.globally_resolve_keys?
    verifier.globally_resolve_keys = true
  end

  test 'Verifier class will not verify health cards when key is not resolvable' do
    skip('Key resolution not implemented')
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
