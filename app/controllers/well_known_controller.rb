# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def smart
    render json: Rails.application.config.smart
  end

  def jwks
    render json: key_set
  end

  private

  def key_set
    key = Rails.application.config.hc_key.public_key
    HealthCards::Key::Set.new(key)
  end
end
