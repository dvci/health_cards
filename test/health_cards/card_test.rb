# frozen_string_literal: true

require 'test_helper'

# TODO: This should be a regular MiniTest::Test for the health_card library
class CardTest < ActiveSupport::TestCase
  setup do
    @key_path = rails_key_path
    @private_key = HealthCards::PrivateKey.from_file!(@key_path)
    @public_key = @private_key.public_key
    @payload = 'foobar'

    @wrong_private_key = HealthCards::PrivateKey.generate_new_key
    @wrong_public_key = @wrong_private_key.public_key
  end

  teardown do
    cleanup_keys
  end

  test 'creating a JWS from a given private key' do
    card = HealthCards::Card.new(payload: @payload, private_key: @private_key)
    jws = card.to_jws
    assert_equal 3, jws.split('.').length
  end

  test 'creating a JWS fails without a private or public key' do
    card = HealthCards::Card.new(payload: @payload)
    assert_raises HealthCards::Card::MissingPublicKey do
      card.to_jws
    end
  end

  test 'creating a JWS fails with a public key, but without a private key' do
    card = HealthCards::Card.new(payload: @payload, public_key: @public_key)
    assert_raises HealthCards::Card::MissingPrivateKey do
      card.to_jws
    end
  end

  test 'JWS can be validated' do
    card = HealthCards::Card.new(payload: @payload, private_key: @private_key)
    assert card.verify
    jws = card.to_jws
    assert HealthCards::Card.verify(jws, @public_key)
    assert_not HealthCards::Card.verify(jws, @wrong_public_key)
  end

  test 'JWS will not verify if public key is changed' do
    card = HealthCards::Card.new(payload: @payload, private_key: @private_key)
    assert card.verify
    card.public_key = @wrong_public_key
    assert_not card.verify
  end

  test 'JWS header contains the correct properties' do
    card = HealthCards::Card.new(payload: @payload, private_key: @private_key)
    header = JSON.parse(card.header)
    assert 'DEF', header['zip']
    assert 'ES256', header['alg']
    assert @public_key.thumbprint, header['kid']
  end

  test 'signature resets when private key is changed' do
    card = HealthCards::Card.new(payload: @payload, private_key: @private_key)
    before_signature = card.signature

    assert_equal before_signature, card.signature # Signature is memoized until the private key changes

    # MissingPrivateKey error thrown when private key is not present
    card.private_key = nil
    assert_raises HealthCards::Card::MissingPrivateKey do
      card.signature
    end

    card.private_key = @private_key
    # Different signature with same key. ES256 signatures are non-deterministic for same key and payload
    assert_not_equal before_signature, card.signature
    before_signature = card.signature
    assert before_signature, card.signature

    card.private_key = @wrong_private_key
    assert_not_equal before_signature, card.signature
  end
end
