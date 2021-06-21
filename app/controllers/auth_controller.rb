# frozen_string_literal: true

# AuthController exposes authorization endpoints for users to get access tokens
class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :token
  before_action :set_params
  before_action :set_headers_no_cache

  def authorize
    if valid_request?
      redirect_to "#{@params[:redirect_uri]}?code=#{Rails.application.config.auth_code}&state=#{@params[:state]}"
    else
      render json: { error: 'invalid_request' }, status: :bad_request
    end
  end

  def token
    if valid_request?
      render_new_token
    elsif invalid_client?
      render json: { error: 'invalid_client' }, status: :bad_request
    elsif invalid_grant?
      render json: { error: 'invalid_grant' }, status: :bad_request
    elsif invalid_grant_type?
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

  def set_params
    @params = request.parameters
  end

  def valid_request?
    if @params[:action] == 'token'
      @params[:client_id] == Rails.application.config.client_id &&
        @params[:code] == Rails.application.config.auth_code &&
        (@params[:grant_type] == 'authorization_code' || !@params.key?(:grant_type))
    else
      @params[:client_id] == Rails.application.config.client_id && @params.key?(:redirect_uri)
    end
  end

  # only call for /auth/token
  def invalid_grant?
    @params[:client_id] && @params[:code] && @params[:code] != Rails.application.config.auth_code
  end

  def invalid_client?
    if @params[:action] == 'token'
      @params[:client_id] && @params[:client_id] != Rails.application.config.client_id && @params[:code]
    else
      @params[:client_id] && @params[:client_id] != Rails.application.config.client_id
    end
  end

  # only call for /auth/token
  # will only return false if the grant type is explicitly declared incorrectly
  # OAuth2 requires grant type to be specified, but SMART on FHIR does not
  def invalid_grant_type?
    @params.key?(:grant_type) && @params[:grant_type] != 'authorization_code'
  end

  # only call for /auth/token
  def render_new_token
    time_to_live = 1.hour
    scope = ['launch/patient', 'patient/Immunization.read']
    header = { alg: 'ES256' }
    payload = { exp: Time.now.to_i + time_to_live, scope: scope }
    jws = HealthCards::JWS.new(header: header, payload: payload.to_json, key: Rails.application.config.hc_key)
    new_token = {
      access_token: jws.to_s,
      token_type: 'Bearer',
      expires_in: time_to_live,
      scope: scope,
      patient: Patient.first&.id
    }
    render json: new_token
  end
end
