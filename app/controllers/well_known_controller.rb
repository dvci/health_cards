# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def smart
    render json: Rails.application.config.smart.to_json
  end

  def jwks
    @key = Rails.application.config.hc_key
    render json: JSON.pretty_generate(@key.to_json)
  end
end
