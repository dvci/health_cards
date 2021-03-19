# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def smart
    render json: config.smart.to_json
  end

  def jwks
    @issuer = HealthCards::Issuer.new config.jwk[:key_path]
    render json: JSON.pretty_generate(@issuer.jwks)
  end

  private

  def config
    Rails.application.config.well_known
  end
end
