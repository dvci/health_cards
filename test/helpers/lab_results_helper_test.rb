require 'test_helper'
FILEPATH_PAYLOAD_MINIFIED = 'example-jws-payload-minified'

class HealthCardsHelperTest < ActiveSupport::TestCase
  include HealthCardsHelper

  setup do
    Vaccine.create(code: '207')
    @jws_payload = load_json_fixture(FILEPATH_PAYLOAD_MINIFIED)
  end

  test ''
end
