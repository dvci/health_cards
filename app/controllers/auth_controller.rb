# frozen_string_literal: true

# AuthController exposes authorization endpoints for users to get access tokens
class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :token

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
      time_to_live = 1.hour
      scope = ['launch/patient', 'patient/Immunization.read']
      header = { alg: 'ES256' }
      payload = { exp: Time.now.to_i + time_to_live, scope: scope }
      jws = HealthCards::JWS.new(header: header, payload: payload.to_json, key: Rails.application.config.hc_key)
      render json: {
        access_token: jws.to_s,
        token_type: 'Bearer',
        expires_in: time_to_live,
        scope: scope,
        patient: Patient.all.first.id
      }
    else
      render_operation_outcome(code: 'unknown', http: :unauthorized, message: 'Unauthorized Code')
    end
  end
end
