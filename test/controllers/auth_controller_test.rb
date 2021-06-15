# frozen_string_literal: true

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test 'authorize without client_id should return 400 invalid_request' do
    get(auth_code_path)

    print @response.headers.to_s

    assert_response :bad_request
    assert_no_cache_headers
    assert_equal @response.body, '{"error": "invalid_request"}'
  end

  test 'authorize with incorrect client_id should return 400 invalid_client' do
    get(auth_code_path, params: { client_id: 'bad_id' })
    assert_response :bad_request
    assert_no_cache_headers
    assert_equal @response.body, '{"error": "invalid_client"}'
  end

  test 'authorize with correct client_id redirects with auth_code' do
    redirect_uri = 'http://example.com'
    state = 'test_state'
    get(auth_code_path,
        params: { client_id: Rails.application.config.client_id, redirect_uri: redirect_uri, state: state })
    assert_redirected_to "#{redirect_uri}?code=#{Rails.application.config.auth_code}&state=#{state}"
    assert_no_cache_headers
  end

  test 'token with incorrect code should return 400 invalid_client' do
    post(auth_token_path, params: { code: 'bad_code' })
    assert_response :bad_request
    assert_no_cache_headers
    assert_equal @response.body, '{"error": "invalid_client"}'
  end

  test 'token with correct code' do
    post(auth_token_path, params: { code: Rails.application.config.auth_code })
    assert_response :success
    assert_no_cache_headers
  end

  private
    def assert_header( key, value )
      assert_equal @response.headers[key], value
    end

    def assert_no_cache_headers
      assert_header( 'cache-control', 'no-store' )
      assert_header( 'pragma', 'no-cache' )
    end
end
