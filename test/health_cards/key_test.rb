# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class KeyTest < ActiveSupport::TestCase
  setup do
    @key_path = Rails.application.config.hc_key_path
    @rails_key = Rails.application.config.hc_key
    @key = HealthCards::Key.load_file(@key_path)
  end

  teardown do
    FileUtils.rm @key_path if File.exist?(@key_path)
  end

  test 'creates keys' do
    assert_path_exists(@key_path)
  end

  test 'exports to jwk' do
    jwks = @key.to_json
    assert_equal 1, jwks[:keys].length

    jwks[:keys].one? do |key|
      assert_equal 'sig', key['use']
      assert_equal 'ES256', key['alg']
    end
  end

  test 'Use existing keys if they exist' do
    original_jwks = @key.to_json

    new_jwks = HealthCards::Key.load_file(@key_path).to_json

    assert_equal original_jwks, new_jwks
  end

  test 'create a signed jws' do
    card = HealthCards::Card.new(@key, 'asdfasdf')
    header, payload, sigg = card.jws.split('.')
    assert card.verify
    assert @key.signing_key.dsa_verify_asn1(payload, Base64.urlsafe_decode64(sigg))
    assert_not @key.signing_key.dsa_verify_asn1('asdf', Base64.urlsafe_decode64(sigg))
    assert_equal 'asdfasdf', Base64.urlsafe_decode64(payload)

    decoded_header = JSON.parse(Base64.urlsafe_decode64(header))
    assert_equal 'DEF', decoded_header['zip']
    assert_equal 'ES256', decoded_header['alg']
    assert decoded_header['kid']
  end
end
