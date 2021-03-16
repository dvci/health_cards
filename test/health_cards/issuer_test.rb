# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'health_cards/issuer'

class IssuerTest < ActiveSupport::TestCase
  setup do
    FileUtils.rm_rf Configuration.key_path
  end

  test 'Creates keys' do
    issuer = HealthCards::Issuer.new Configuration.key_path
    jwks = issuer.jwks

    assert_path_exists(issuer.signing_key_path)
    assert_equal 1, jwks[:keys].length
    assert(jwks[:keys].one? { |key| key[:use] == 'sig' && key[:alg] == 'ES256' })
  end

  test 'Use existing keys if they exist' do
    issuer = HealthCards::Issuer.new Configuration.key_path
    original_jwks = issuer.jwks

    new_issuer = HealthCards::Issuer.new Configuration.key_path
    new_jwks = new_issuer.jwks

    assert_equal original_jwks, new_jwks
  end
end