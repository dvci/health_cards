# frozen_string_literal: true

require 'test_helper'

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  setup do
    @well_known = Rails.application.config.smart
    @key = rails_public_key
  end

  teardown do
    cleanup_keys
  end

  test 'supports health cards' do
    get(well_known_smart_url)
    assert_response :success

    config = JSON.parse(response.body)
    assert_equal @well_known, config.symbolize_keys
  end

  test 'supports jwks' do
    get(well_known_jwks_url)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['keys'].length
    response_key = json['keys'].first
    @key.to_json.each_pair do |att, val|
      assert_equal val.to_s, response_key[att]
    end

    assert_not response_key.key?('d')
  end
end
