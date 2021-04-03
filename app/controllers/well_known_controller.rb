# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def smart
    render json: Rails.application.config.smart.to_json
  end

  def jwks
    render json: JSON.pretty_generate(key_set.to_json)
  end

  private

  def key_set
    key = Rails.application.config.hc_public_key
    HealthCards::Key::Set.new(key)
  end
end
