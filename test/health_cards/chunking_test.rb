# frozen_string_literal: true

require 'test_helper'
require 'health_cards/chunking'

JWS_SMALL = 's' * 1195
JWS_LARGE = 'l' * 1196

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

  test 'Individual chunks of split-up JWS have string sizes of < 1191 characters' do
    large_jws_split = @dummy_class.split_bundle(JWS_LARGE)
    large_jws_split.each do |chunk|
      assert_operator(1191, :>=, chunk.length)
    end
  end
end
