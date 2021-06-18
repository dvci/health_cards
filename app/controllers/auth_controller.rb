# frozen_string_literal: true

# AuthController exposes authorization endpoints for users to get access tokens
class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :token
  before_action :set_headers_no_cache

  def authorize
    params = request.params
    if params[:client_id] == Rails.application.config.client_id
      redirect_to "#{params[:redirect_uri]}?code=#{Rails.application.config.auth_code}&state=#{params[:state]}"
    elsif params.key? :client_id
      render json: { error: 'invalid_client' }, status: :bad_request
    else
      render json: { error: 'invalid_request' }, status: :bad_request
    end
  end

  def token
    params = request.parameters
    if params[:code] == Rails.application.config.auth_code && params[:client_id] == Rails.application.config.client_id
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
        patient: Patient.first&.id
      }
    elsif params.key?(:code) && params[:client_id] == Rails.application.config.client_id
      render json: { error: 'invalid_grant' }, status: :bad_request
    elsif params.key?(:code) && params.key?(:client_id)
      render json: { error: 'invalid_client' }, status: :bad_request
    elsif params.key?(:grant_type) && params[:grant_type] != 'authorization_code'
      render json: { error: 'invalid_grant_type' }, status: :bad_request
    else
      render json: { error: 'invalid_request' }, status: :bad_request
    end
  end

  private

  def set_headers_no_cache
    response.set_header 'Cache-Control', 'no-store'
    response.set_header 'Pragma', 'no-cache'
    response.set_header 'Last-Modified', Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S %Z')
  end
end
