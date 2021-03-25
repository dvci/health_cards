# frozen_string_literal: true

require 'test_helper'
require 'health_cards/issuer'

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  setup do
    @well_known = Rails.application.config.well_known
    @issuer = Rails.application.config.issuer
  end

  teardown do
    key_path  = @well_known.jwk[:key_path]
    FileUtils.rm_rf Pathname.new(key_path).join(HealthCards::FileKeyStore::FILE_NAME)
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

    json = JSON.parse(response.body)
    assert_equal 1, json['keys'].length
    response_key = json['keys'].first
    @issuer.jwks[:keys].one? do |key|
      key.each_pair do |att, val|
        assert_equal val.to_s, response_key[att]
      end

      assert_not response_key.key?('d')
    end
  end
end
