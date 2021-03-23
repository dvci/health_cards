# frozen_string_literal: true

require 'test_helper'

class HealthCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(given: 'foo')
  end

  test 'get health card download' do
    get(patient_health_card_path(@patient, format: :healthcard))
  end
end
