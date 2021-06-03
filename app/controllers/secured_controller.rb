# frozen_string_literal: true

# SecuredController checks access token before authorizing requests
class SecuredController < ApplicationController
  before_action :authorize_request

  private

  def get_access_token(headers)
    headers['Authorization'].split.last if headers['Authorization'].present?
  end

  def authorize_request
    headers = request.headers
    access_token = get_access_token headers
    return if access_token.nil?

    jws = HealthCards::JWS.from_jws(access_token, key: Rails.application.config.hc_key)
    # Verify token signature
    render json: { errors: ['Unauthorized code'] }, status: :unauthorized unless jws.verify
    # Check if token is expired
    return unless Time.now.to_i > JSON.parse(jws.payload)['exp']

    render json: { errors: ['Expired Access Token'] }, status: :unauthorized
  end
end
