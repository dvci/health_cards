# frozen_string_literal: true

require 'test_helper'

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  test 'supports health cards' do
    get(well_known_url)
    assert_response :success

    config = JSON.parse(response.body)
    assert_equal Rails.configuration.well_known, config
  end
end
