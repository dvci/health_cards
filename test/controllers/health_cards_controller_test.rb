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
    assert_not_nil json['verifiableCredential']
    assert_equal 1, json['verifiableCredential'].size

    jwt = JSON::JWT.decode(json['verifiableCredential'].first, @issuer.public_key)
    entries = jwt.dig('credentialSubject', 'fhirBundle', 'entry')
    assert_not_nil entries
    name = entries[0].dig('resource', 'name')
    assert_not_nil name
    assert_equal @patient.given, name.first['given'][0]
    assert_response :success
  end
end
