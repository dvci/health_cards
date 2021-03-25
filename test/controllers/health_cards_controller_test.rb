# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
    @issuer = Rails.application.config.issuer
  end

  test 'get health card download' do
    get(patient_health_card_path(@patient, format: 'smart-health-card'))
    json = JSON.parse(response.body)
    vc = json['verifiableCredential']

    assert_not_nil vc
    assert_equal 1, vc.size

    assert_nothing_raised do
      JSON::JWT.decode(vc.first, @issuer.public_key)
    end

    assert_response :success
  end
end
