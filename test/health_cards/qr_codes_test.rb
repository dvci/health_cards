# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class QrCodesTest < ActiveSupport::TestCase
  setup do
    @jws = HealthCards::JWS.from_jws(load_json_fixture('example-jws-multiple'))
    @chunks = load_json_fixture('example-numeric-qr-code')
  end

  test 'chunk converts to valid code' do
    codes = HealthCards::QRCodes.new(@chunks)
    # codes.chunks[0].image.save('test/fixtures/files/qr/single.png')  For use when qr code images need to be updated
    image = ChunkyPNG::Image.from_file('test/fixtures/files/qr/single.png')

    assert_equal 1, codes.chunks.length
    assert_equal @chunks[0], codes.chunks[0].data
    assert_equal image, codes.chunks[0].image
  end

  test 'initialize codes from jws' do
    codes = HealthCards::QRCodes.from_jws(@jws)

    assert_equal 3, codes.chunks.length

    codes.chunks.each.with_index(1) do |ch, i|
      # ch.image.save("test/fixtures/files/qr/#{i}.png") For use when qr code images need to be updated
      image = ChunkyPNG::Image.from_file("test/fixtures/files/qr/#{i}.png")
      assert_equal image, ch.image
    end
  end
end
