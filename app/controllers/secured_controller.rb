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

    # Verify token signature and expiration
    JWT.decode(access_token, Rails.application.config.hc_key.key, true, { algorithm: 'ES256' }).first
  rescue JWT::ExpiredSignature
    render json: { errors: ['Expired Access Token'] }, status: :unauthorized
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Unauthorized code'] }, status: :unauthorized
  end
end
