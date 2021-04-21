# frozen_string_literal: true

require 'test_helper'

class IssuerTest < ActiveSupport::TestCase
  setup do
    @bundle = bundle_payload
    @private_key = private_key
  end

  ## Constructors

  test 'Create a new Issuer' do
    HealthCards::Issuer.new(key: @private_key)
  end

  test 'Issuer raises exception when initializing with public key' do
    assert_raises HealthCards::MissingPrivateKey do
      HealthCards::Issuer.new(key: @private_key.public_key)
    end
  end

  ## Creating Health Cards

  test 'Generate a health card from an Issuer' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    assert health_card.is_a?(HealthCards::HealthCard) # Should be a HealthCard or subclass of HealthCard
  end

  test 'Issuer throws exception when attempting to generate health card without a private key' do
    issuer = HealthCards::Issuer.new
    assert_raises HealthCards::MissingPrivateKey do
      issuer.create_health_card @bundle
    end
  end

  ## Key Export

  test 'Issuer exports public keys as JWK' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    key = issuer.key
    assert key.is_a? HealthCards::PrivateKey
  end

  ## Adding and Removing Keys

  test 'Issuer allows private keys to be added' do
    issuer = HealthCards::Issuer.new
    assert_nil issuer.key
    issuer.key = @private_key
    assert_not_nil issuer.key
    assert_equal issuer.key, @private_key
  end

  test 'Issuer allows private keys to be removed' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    assert_not_nil issuer.key
    assert_equal issuer.key, @private_key
    issuer.key = nil
    assert_nil issuer.key
  end

  test 'Issuer does not allow public key to be added' do
    issuer = HealthCards::Issuer.new
    assert_raises HealthCards::MissingPrivateKey do
      issuer.key = @private_key.public_key
    end
  end

  ## Integration Tests

  test 'Issuer issues Health Cards that can be exported as JWS' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    health_card.to_jws
  end

  test 'Issuer signed Health Cards are signed with set private key' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    health_card.key = nil
    assert_raises HealthCards::MissingPublicKey do
      health_card.verify
    end
    health_card.public_key = @private_key.public_key
    assert health_card.verify
  end
end
