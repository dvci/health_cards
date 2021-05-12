# frozen_string_literal: true

require 'test_helper'

class PrivateKeyTest < Minitest::Test
  def setup
    # Key from https://datatracker.ietf.org/doc/html/rfc7515#appendix-A.3.1
    @jwk = {"kty":"EC",
            "crv":"P-256",
            "x":"f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
            "y":"x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0",
            "d":"jpsQnnGQmL-YBIffH1136cspYG6-0iY7X1fCE9-E9LI"
    }

    @key = HealthCards::PrivateKey.from_jwk(@jwk)

    @encoder = Class.new
    @encoder.extend(HealthCards::Encoding)
  end

  def test_signing_payloads
    # Examples from https://datatracker.ietf.org/doc/html/rfc7515#appendix-A.3.1
    payload = 'eyJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ'
    signature = @key.sign(payload)
    assert_equal @encoder.encode(signature), 'DtEhU3ljbEg8L38VWAfUAqOyKAM6-Xx-F4GawxaepmXFCgfTjDxw5djxLa8ISlSApmWQxfKTUJqPP3-Kg6NU1Q'
  end
end