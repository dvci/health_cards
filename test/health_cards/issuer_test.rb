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
    assert_raises HealthCards::InvalidKeyException do
      HealthCards::Issuer.new(key: @private_key.public_key)
    end
  end

  ## Creating Health Cards

  test 'Generate a health card from an Issuer' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    assert health_card.is_a?(HealthCards::HealthCard) # Should be a HealthCard or subclass of HealthCard
  end

  ## Key Export

  test 'Issuer exports public key as JWK' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    key = JSON.parse(issuer.to_jwk)
    # TODO: Add more checks once we can ingest external public keys
    assert issuer.key.public_key.kid, key['kid']
  end

  ## Adding and Changing Keys

  test 'Issuer allows private keys to be changed' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    key2 = HealthCards::PrivateKey.generate_key
    issuer.key = key2
    assert_not_nil issuer.key
    assert_not_equal issuer.key, @private_key
  end

  test 'Issuer does not allow public key to be added' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    assert_raises HealthCards::InvalidKeyException do
      issuer.key = @private_key.public_key
    end
  end

  ## Integration Tests

  test 'Issuer issues Health Cards that can be exported as JWS' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    assert_not_nil health_card.jws
  end

  test 'Issuer signed Health Cards are signed with set private key' do
    issuer = HealthCards::Issuer.new(key: @private_key)
    health_card = issuer.create_health_card(@bundle)
    assert health_card.jws.verify
  end
end
