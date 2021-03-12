# frozen_string_literal: true

# WellKnownController exposes the .well-known configuration to identify relevant urls and server capabilities
class WellKnownController < ApplicationController
  def index
    render json: Rails.configuration.well_known.to_json
  end
end
