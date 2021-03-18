# frozen_string_literal: true

require 'test_helper'
require 'health_cards/chunking'

FILEPATH_SMALL = 'test/fixtures/files/example-00-d-jws.txt'
FILEPATH_LARGE = 'test/fixtures/files/example-02-d-jws.txt'

class ChunkingTest < ActiveSupport::TestCase
  class DummyClass
    # Dummy Class used for testing module methods
    include HealthCards::Chunking
  end

  setup do
    @dummy_class = DummyClass.new
    @dummy_class.extend(HealthCards::Chunking)

    @small_jws = File.read(FILEPATH_SMALL).split[0]
    @small_jws_split = @dummy_class.split_bundle(@small_jws)

    @large_jws = File.read(FILEPATH_LARGE).split[0]
    @large_jws_split = @dummy_class.split_bundle(@large_jws)
  end

  test 'A JWS of size <= 1195 returns only one chunk' do
    assert_equal(1, @small_jws_split.length)
  end

  test 'A JWS of size > 1195 returns multiple chunks' do
    assert_operator(1, :<, @large_jws_split.length)
  end

  test 'Individual chunks of split-up JWS have string sizes of < 1191 characters' do
    @large_jws_split.each do |chunk|
      assert_operator(1191, :>=, chunk.length)
    end
  end
end
