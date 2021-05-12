# frozen_string_literal: true

require 'test_helper'

class EncodingTest < Minitest::Test
  def setup
    @klass = Class.new
    @klass.extend(HealthCards::Encoding)
  end

  def test_encodes_header_correctly
    # Examples from: https://datatracker.ietf.org/doc/html/rfc7515
    {
      '{"alg":"ES256"}' => 'eyJhbGciOiJFUzI1NiJ9',
      "{\"typ\":\"JWT\",\r\n \"alg\":\"HS256\"}" => 'eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9'
    }.each do |header, expected_base64url|
      assert_equal @klass.encode(header), expected_base64url
    end
  end

  def test_encodes_payload_correctly
    # Examples from: https://datatracker.ietf.org/doc/html/rfc7515
    {
      "{\"iss\":\"joe\",\r\n \"exp\":1300819380,\r\n \"http://example.com/is_root\":true}" => 'eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ',
      'Payload' => 'UGF5bG9hZA'
    }.each do |payload, expected_base64url|
      assert_equal @klass.encode(payload), expected_base64url
    end
  end
end
