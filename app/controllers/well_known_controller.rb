# frozen_string_literal: true

require_relative '../../lib/health_cards'

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def index
    render json: Rails.configuration.well_known.to_json
  end

  def jwks
    @issuer = HealthCards::Issuer.new ::Configuration.key_path
    render json: JSON.pretty_generate(@issuer.jwks)
  end
end
