# frozen_string_literal: true

# AuthController exposes authorization endpoints for users to get access tokens
class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :token
  after_action :set_cors_header, only: :token

  def authorize
    params = request.params
    if params[:client_id] == Rails.application.config.client_id
      redirect_to "#{params[:redirect_uri]}?code=#{Rails.application.config.auth_code}&state=#{params[:state]}"
    else
      render json: { errors: ['Unauthorized client_id'] }, status: :unauthorized
    end
  end

  def token
    params = request.parameters
    if params[:code] == Rails.application.config.auth_code
      scope = ['launch/patient', 'patient/Immunization.read']
      payload = { exp: helpers.convert_time_to_epoch(Time.current + 3600), scope: scope }
      token = JWT.encode payload, Rails.application.config.hc_key.key, 'ES256'
      render json: {
        access_token: token,
        token_type: 'Bearer',
        expires_in: 3600,
        scope: scope,
        patient: Patient.all.first.id
      }
    else
      render json: { errors: ['Unauthorized code'] }, status: :unauthorized
    end
  end
end
