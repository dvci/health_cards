# frozen_string_literal: true

require 'test_helper'
require 'health_cards/chunking'

JWS_SMALL = 's' * 1195
JWS_LARGE = 'l' * 1196
JWS_3 = "#{'t' * 1191 * 2}t"

FILEPATH_NUMERIC_QR_CODE = 'test/fixtures/files/example-numeric-qr-code.json'
FILEPATH_NUMERIC_QR_CODE_MULTIPLE = 'test/fixtures/files/example-numeric-qr-code-multiple.json'
FILEPATH_JWS = 'test/fixtures/files/example-jws.json'
FILEPATH_JWS_MULTIPLE = 'test/fixtures/files/example-jws-multiple.json'
FILEPATH_PAYLOAD_MINIFIED = 'test/fixtures/files/example-jws-payload-minified.json'

class ChunkingTest < ActiveSupport::TestCase
  setup do
    @dummy_class = Class.new
    @dummy_class.extend(HealthCards::Chunking)
  end

  test 'A JWS of size <= 1195 returns only one chunk' do
    small_jws_split = @dummy_class.split_bundle(JWS_SMALL)
    assert_equal(1, small_jws_split.length)
  end

  test 'A JWS of size > 1195 returns multiple chunks' do
    large_jws_split = @dummy_class.split_bundle(JWS_LARGE)
    assert_operator(1, :<, large_jws_split.length)
  end

  test 'A JWS of size 1191 * 2 + 1 characters returns 3 chunks' do
    thrice_jws_split = @dummy_class.split_bundle(JWS_3)
    assert_equal(3, thrice_jws_split.length)
  end

  test 'Individual chunks of split-up JWS have string sizes of < 1191 characters' do
    large_jws_split = @dummy_class.split_bundle(JWS_LARGE)
    large_jws_split.each do |chunk|
      assert_operator(1191, :>=, chunk.length)
    end
  end

  test 'A JWS of size <= 1195 returns one QR chunk' do
    small_qr_chunk = @dummy_class.generate_qr_chunks(JWS_SMALL)
    assert_equal(1, small_qr_chunk.length)
    expected_result = [JWS_SMALL.chars.map { |c| format('%02d', c.ord - 45) }.join]
    assert_equal(expected_result, small_qr_chunk)
  end

  test 'A JWS of size 1191 * 2 + 1 characters returns 3 QR chunks' do
    qr_chunks = @dummy_class.generate_qr_chunks(JWS_3)
    assert_equal(3, qr_chunks.length)
    expected_result = @dummy_class.split_bundle(JWS_3).map { |c| c.chars.map { |ch| format('%02d', ch.ord - 45) }.join }
    assert_equal(expected_result, qr_chunks)
  end

  test 'A single numeric QR code returns correctly assembled JWS' do
    qr_file = File.read(FILEPATH_NUMERIC_QR_CODE)
    qr_chunks = JSON.parse(qr_file)
    jws_file = File.read(FILEPATH_JWS)
    expected_jws = JSON.parse(jws_file)

    assembled_jws = @dummy_class.assemble_jws qr_chunks
    assert_equal expected_jws, assembled_jws
  end

  test 'Multiple QR codes return correctly assembled JWS' do
    qr_file = File.read(FILEPATH_NUMERIC_QR_CODE_MULTIPLE)
    qr_chunks = JSON.parse(qr_file)
    jws_file = File.read(FILEPATH_JWS_MULTIPLE)
    expected_jws = JSON.parse(jws_file)

    assembled_jws = @dummy_class.assemble_jws qr_chunks
    assert_equal expected_jws, assembled_jws
  end

  test 'VC should get returned from QR code' do
    qr_file = File.read(FILEPATH_NUMERIC_QR_CODE)
    qr_chunks = JSON.parse(qr_file)
    jws_payload = File.read(FILEPATH_PAYLOAD_MINIFIED)
    payload = JSON.parse(jws_payload)
    decoded_payload = @dummy_class.get_payload_from_qr qr_chunks

    assert_equal payload['vc'], decoded_payload['vc']
  end
end
