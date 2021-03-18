# frozen_string_literal: true

require 'test_helper'
require 'health_cards/issuer'

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  setup do
    @well_known = Rails.application.config.well_known
    @key_path = @well_known.jwk[:key_path]
  end

  teardown do
    FileUtils.rm_rf @key_path
  end

  test 'supports health cards' do
    get(well_known_smart_url)
    assert_response :success

    config = JSON.parse(response.body)
    assert_equal @well_known.smart, config.symbolize_keys
  end

  test 'supports jwks' do
    get(well_known_jwks_url)
    assert_response :success

    issuer = HealthCards::Issuer.new @key_path
    assert_equal JSON.pretty_generate(issuer.jwks), response.body
  end
end
