# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  after_action :set_cors_header

  def smart
    render json: Rails.application.config.smart
  end

  def jwks
    render json: key_set.to_jwk
  end

  private

  def key_set
    key = Rails.application.config.hc_key.public_key
    HealthCards::KeySet.new(key)
  end
end
