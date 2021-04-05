# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class KeyTest < ActiveSupport::TestCase
  setup do
    @key_path = rails_key_path
    @key = HealthCards::PrivateKey.from_file!(@key_path)
  end

  teardown do
    cleanup_keys
  end

  test 'creates keys' do
    assert_path_exists(@key_path)
  end

  test 'exports to jwk' do
    jwks = HealthCards::Key::Set.new(@key.public_key).to_json
    assert_equal 1, jwks[:keys].length
    jwk = jwks[:keys].first
    assert_equal 'sig', jwk['use']
    assert_equal 'ES256', jwk['alg']
  end

  test 'Use existing keys if they exist' do
    original_jwks = @key.public_key.to_json

    new_jwks = HealthCards::PrivateKey.from_file!(@key_path).public_key.to_json

    assert_equal original_jwks, new_jwks
  end

  test 'create a signed jws' do
    card = HealthCards::Card.new(private_key: @key, public_key: @key.public_key, payload: 'asdfasdf')
    header, payload, sigg = card.to_jws.split('.')
    assert card.verify
    assert @key.public_key.verify(payload, Base64.urlsafe_decode64(sigg))
    assert_not @key.public_key.verify('asdf', Base64.urlsafe_decode64(sigg))
    assert_equal 'asdfasdf', Base64.urlsafe_decode64(payload)

    decoded_header = JSON.parse(Base64.urlsafe_decode64(header))
    assert_equal 'DEF', decoded_header['zip']
    assert_equal 'ES256', decoded_header['alg']
    assert decoded_header['kid']
  end
end
