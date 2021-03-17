# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/health_cards/issuer'

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  test 'supports health cards' do
    get(well_known_url)
    assert_response :success

    config = JSON.parse(response.body)
    assert_equal Rails.configuration.well_known, config
  end

  test 'supports jwks' do
    get(well_known_jwks_url)
    assert_response :success

    issuer = HealthCards::Issuer.new Configuration.key_path
    assert_equal JSON.pretty_generate(issuer.jwks), response.body
  end
end
