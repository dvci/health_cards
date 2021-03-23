# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'health_cards/issuer'

class IssuerTest < ActiveSupport::TestCase
  setup do
    @key_path = Rails.application.config.well_known.jwk[:key_path]
    @file_store = HealthCards::FileKeyStore.new(@key_path)
  end

  teardown do
    FileUtils.rm_rf @key_path
  end

  test 'Creates keys' do
    issuer = HealthCards::Issuer.new @file_store
    jwks = issuer.jwks

    assert_path_exists(@file_store.key_path)
    assert_equal 1, jwks[:keys].length
    jwks[:keys].one? do |key|
      assert_equal 'sig', key['use']
      assert_equal 'ES256', key['alg']
    end
  end

  test 'Use existing keys if they exist' do
    issuer = HealthCards::Issuer.new @file_store
    original_jwks = issuer.jwks

    new_issuer = HealthCards::Issuer.new @file_store
    new_jwks = new_issuer.jwks

    assert_equal original_jwks, new_jwks
  end
end
