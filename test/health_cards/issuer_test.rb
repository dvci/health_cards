# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'health_cards/issuer'

class IssuerTest < ActiveSupport::TestCase
  setup do
    @key_path = Rails.application.config.well_known.jwk[:key_path]
    @file_store = HealthCards::FileKeyStore.new(@key_path)
    @issuer = HealthCards::Issuer.new(@file_store)
  end

  teardown do
    FileUtils.rm File.join(@key_path, HealthCards::FileKeyStore::FILE_NAME)
    FileUtils.rmdir @key_path
  end

  test 'creates keys' do
    jwks = @issuer.jwks

    assert_path_exists(@file_store.key_path)
    assert_equal 1, jwks[:keys].length
    jwks[:keys].one? do |key|
      assert_equal 'sig', key['use']
      assert_equal 'ES256', key['alg']
    end
  end

  test 'created signed jwt' do
    vc = HealthCards::VerifiableCredential.new({})
    signed_jwt = @issuer.sign(vc, 'http://example.com')
    assert_instance_of String, signed_jwt
    jwt = {}
    assert_nothing_raised do
      jwt = JSON::JWT.decode(signed_jwt, @issuer.public_key)
    end
    assert_not_nil jwt['iss']
    assert_not_nil jwt['nbf']
  end

  test 'Use existing keys if they exist' do
    original_jwks = @issuer.jwks

    new_issuer = HealthCards::Issuer.new @file_store
    new_jwks = new_issuer.jwks

    assert_equal original_jwks, new_jwks
  end
end
