# frozen_string_literal: true

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test 'authorize without client_id should return 400 invalid_request' do
    get(auth_code_path)
    assert_response :bad_request
    assert_equal('{"error":"invalid_request"}', @response.body)
  end

  test 'authorize with incorrect client_id should return 400 invalid_client' do
    get(auth_code_path, params: { client_id: 'bad_id' })
    assert_response :bad_request
    assert_equal('{"error":"invalid_client"}', @response.body)
  end

  test 'authorize with correct parameters should redirect with auth_code' do
    redirect_uri = 'http://example.com'
    state = 'test_state'
    get(auth_code_path,
        params: { client_id: Rails.application.config.client_id,
                  code: Rails.application.config.auth_code,
                  redirect_uri: redirect_uri,
                  state: state })
    assert_redirected_to "#{redirect_uri}?code=#{Rails.application.config.auth_code}&state=#{state}"
  end

  test 'token with no parameters should return 400 invalid_request' do
    post(auth_token_path)
    assert_response :bad_request
    assert_equal('{"error":"invalid_request"}', @response.body)
  end

  test 'token with missing client_id parameter should return 400 invalid_request' do
    post(auth_token_path, params: { code: Rails.application.config.client_id })
    assert_response :bad_request
    assert_equal('{"error":"invalid_request"}', @response.body)
  end

  test 'token with missing code parameter should return 400 invalid_request' do
    post(auth_token_path, params: { client_id: Rails.application.config.client_id })
    assert_response :bad_request
    assert_equal('{"error":"invalid_request"}', @response.body)
  end

  test 'token with incorrect parameters should return 400 invalid_client' do
    post(auth_token_path, params: { code: 'bad_code', client_id: 'bad_client' })
    assert_response :bad_request
    assert_equal('{"error":"invalid_client"}', @response.body)
  end

  test 'token with incorrect client_id should return 400 invalid_client' do
    post(auth_token_path, params: { code: Rails.application.config.auth_code, client_id: 'bad_client' })
    assert_response :bad_request
    assert_equal('{"error":"invalid_client"}', @response.body)
  end

  test 'token with incorrect code should return 400 invalid_grant' do
    post(auth_token_path, params: { code: 'bad_code', client_id: Rails.application.config.client_id })
    assert_response :bad_request
    assert_equal('{"error":"invalid_grant"}', @response.body)
  end

  test 'token with explicit incorrect grant_type should return 400 invalid_grant_type' do
    post(auth_token_path, params: { grant_type: 'client_credentials' })
    assert_response :bad_request
    assert_equal('{"error":"invalid_grant_type"}', @response.body)
  end

  test 'token with correct parameters should return 200' do
    post(auth_token_path,
         params: { code: Rails.application.config.auth_code,
                   client_id: Rails.application.config.client_id })
    assert_response :success
  end

  test 'token with correct parameters should return valid token' do
    post(auth_token_path,
         params: { code: Rails.application.config.auth_code,
                   client_id: Rails.application.config.client_id })
    body = JSON.parse(@response.body)
    assert body.key? 'access_token'
    assert_equal('Bearer', body['token_type'])
    assert body.key? 'scope'
    assert body['expires_in'].to_i <= 3600 if body.key? 'expired_in'
  end

  test 'authorize endpoint should disable caching' do
    get(auth_code_path)
    assert_no_cache_headers
  end

  test 'token endpoint should disable caching' do
    post(auth_token_path)
    assert_no_cache_headers
  end

  private

  def assert_header(key, value)
    assert_equal @response.headers[key], value
  end

  def assert_no_cache_headers
    assert_header('Cache-Control', 'no-store')
    assert_header('Pragma', 'no-cache')
  end
end
