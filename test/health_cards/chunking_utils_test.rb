# frozen_string_literal: true

require 'test_helper'
require 'health_cards/chunking_utils'

JWS_SMALL = 's' * 1195
JWS_LARGE = 'l' * 1196
JWS_3 = "#{'t' * 1191 * 2}t"

FILEPATH_NUMERIC_QR_CODE = 'example-numeric-qr-code'
FILEPATH_NUMERIC_QR_CODE_MULTIPLE = 'example-numeric-qr-code-multiple'
FILEPATH_JWS = 'example-jws'
FILEPATH_JWS_MULTIPLE = 'example-jws-multiple'

class ChunkingTest < ActiveSupport::TestCase
  test 'Individual chunks of split-up JWS have string sizes of < 1191 characters' do
    large_jws_split = HealthCards::ChunkingUtils.split_jws(JWS_LARGE)
    large_jws_split.each do |chunk|
      assert_operator(1191, :>=, chunk.length)
    end
  end

  test 'A JWS of size <= 1195 returns only one chunk' do
    small_jws_split = HealthCards::ChunkingUtils.jws_to_qr_chunks(JWS_SMALL)
    assert_equal(1, small_jws_split.length)
  end

  test 'A JWS of size > 1195 returns multiple chunks' do
    large_jws_split = HealthCards::ChunkingUtils.jws_to_qr_chunks(JWS_LARGE)
    assert_operator(1, :<, large_jws_split.length)
  end

  test 'A JWS of size 1191 * 2 + 1 characters returns 3 chunks' do
    thrice_jws_split = HealthCards::ChunkingUtils.jws_to_qr_chunks(JWS_3)
    assert_equal(3, thrice_jws_split.length)
  end

  test 'A JWS of size <= 1195 returns one QR chunk' do
    small_qr_chunk = HealthCards::ChunkingUtils.jws_to_qr_chunks(JWS_SMALL)
    assert_equal(1, small_qr_chunk.length)
    expected_result = ["shc:/#{JWS_SMALL.chars.map { |c| format('%02d', c.ord - 45) }.join}"]
    assert_equal(expected_result, small_qr_chunk)
  end

  test 'A JWS of size 1191 * 2 + 1 characters returns 3 QR chunks' do
    qr_chunks = HealthCards::ChunkingUtils.jws_to_qr_chunks(JWS_3)
    assert_equal(3, qr_chunks.length)

    expected_result = HealthCards::ChunkingUtils.split_jws(JWS_3).map.with_index(1) do |c, i|
      "shc:/#{i}/3/#{c.chars.map { |ch| format('%02d', ch.ord - 45) }.join}"
    end
    assert_equal(expected_result, qr_chunks)
  end

  test 'A single numeric QR code returns correctly assembled JWS' do
    qr_chunks = load_json_fixture(FILEPATH_NUMERIC_QR_CODE)
    expected_jws = load_json_fixture(FILEPATH_JWS)
    assembled_jws = HealthCards::ChunkingUtils.qr_chunks_to_jws qr_chunks
    assert_equal expected_jws, assembled_jws
  end

  test 'Multiple QR codes return correctly assembled JWS' do
    qr_chunks = load_json_fixture(FILEPATH_NUMERIC_QR_CODE_MULTIPLE)
    expected_jws = load_json_fixture(FILEPATH_JWS_MULTIPLE)

    assembled_jws = HealthCards::ChunkingUtils.qr_chunks_to_jws qr_chunks
    assert_equal expected_jws, assembled_jws
  end
end
