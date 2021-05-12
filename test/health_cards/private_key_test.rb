# frozen_string_literal: true

require 'test_helper'

class PrivateKeyTest < Minitest::Test
  def setup
    # Key from https://datatracker.ietf.org/doc/html/rfc7515#appendix-A.3.1
    @jwk = {kty: "EC",
            crv: "P-256",
            x:"f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
            y:"x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0",
            d:"jpsQnnGQmL-YBIffH1136cspYG6-0iY7X1fCE9-E9LI"
    }

    @key = HealthCards::PrivateKey.from_jwk(@jwk)

    @encoder = Class.new
    @encoder.extend(HealthCards::Encoding)
  end

  def test_signing_payloads
    # Examples from https://datatracker.ietf.org/doc/html/rfc7515#appendix-A.3.1
    payload = 'eyJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ'
    signature = @key.sign(payload)
    assert @key.public_key.verify(payload, signature)

    public_jwk = @jwk.reject {|k, _v| k == :d}
    jwk_public_key = HealthCards::Key.from_jwk(public_jwk)
    assert jwk_public_key.is_a? HealthCards::PublicKey
    assert jwk_public_key.verify(payload, signature)
  end

  def test_keys_from_jwk_deterministic
    key1 = HealthCards::PrivateKey.from_jwk(@jwk)
    key2 = HealthCards::PrivateKey.from_jwk(@jwk)
    assert_equal key1.kid, key2.kid

    assert_equal @jwk[:x], key1.coordinates[:x]
    assert_equal @jwk[:y], key1.coordinates[:y]

    assert_equal @jwk[:d], key1.coordinates[:d]
    assert_equal key1.coordinates[:d], key2.coordinates[:d]
  end
end