# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class QrCodesTest < ActiveSupport::TestCase
  test 'chunk converts to valid code' do
    input = load_json_fixture('example-numeric-qr-code')

    codes = HealthCards::QRCodes.new(chunks: input)

    image = ChunkyPNG::Image.from_file('test/fixtures/files/qr/single.png')

    assert_equal 1, codes.chunks.length
    assert_equal input[0], codes.chunks[0].data
    assert_equal image, codes.chunks[0].image
  end

  test 'initialize codes from jws' do
    jws = HealthCards::JWS.from_jws(load_json_fixture('example-jws-multiple'))
    codes = HealthCards::QRCodes.new(jws: jws)

    assert_equal 3, codes.chunks.length

    codes.chunks.each.with_index(1) do |ch, i|
      image = ChunkyPNG::Image.from_file("test/fixtures/files/qr/#{i}.png")
      assert_equal image, ch.image
    end
  end
end
