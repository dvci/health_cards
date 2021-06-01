# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class QrCodesTest < ActiveSupport::TestCase
  test 'initialize codes from jws' do
    @jws = HealthCards::JWS.from_jws(load_json_fixture('example-jws-multiple'))
    codes = HealthCards::QRCodes.new(jws: @jws)

    assert_equal 3, codes.chunks.length

    codes.chunks.each_with_index do |ch, i|
      png = ch.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 650
      )

      image = ChunkyPNG::Image.from_file("test/fixtures/files/qr/#{i + 1}.png")
      assert_equal png, image
    end
  end
end
