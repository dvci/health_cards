# frozen_string_literal: true

module AuthHelper
  def get_access_token(headers)
    headers['Authorization'].split.last if headers['Authorization'].present?
  end

  def verify_token(headers)
    access_token = get_access_token headers
    return false if access_token.nil?

    # Verify token signature and retrieve payload
    payload = JWT.decode(access_token, Rails.application.config.hc_key.key, true, { algorithm: 'ES256' }).first
    # Check if token expired
    return false if (Time.current.to_f + 1000).to_i > payload['exp']

    true
  rescue JWT::VerificationError, JWT::DecodeError
    false
  end
end
