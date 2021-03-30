# frozen_string_literal: true

require 'health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def smart
    render json: Rails.application.config.well_known.smart.to_json
  end

  def jwks
    issuer = Rails.application.config.issuer
    render json: JSON.pretty_generate(issuer.jwks)
  end
end
