# frozen_string_literal: true

require 'test_helper'
require 'health_cards/chunking'

FILEPATH_SMALL = 'test/fixtures/example-00-d-jws.txt'
FILEPATH_LARGE = 'test/fixtures/example-02-d-jws.txt'

describe HealthCards::Chunking do
  class DummyClass
  end

  before(:all) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(HealthCards::Chunking)
  end

  describe 'when a jws of size <= 1195 is passed into the bundle splitter' do
    before do
      @small_jws = File.read(FILEPATH_SMALL).split[0]
    end

    it 'returns only 1 chunk' do
      small_jws_split = @dummy_class.split_bundle(@small_jws)
      _(small_jws_split.length).must_equal(1)
    end
  end

  describe 'when a jws of size > 1195 is passed into the bundle splitter' do
    before do
      @large_jws = File.read(FILEPATH_LARGE).split[0]
      @large_jws_split = @dummy_class.split_bundle(@large_jws)
    end

    it 'returns multiple chunks if the string size is > 1195' do
      assert_operator(1, :<, @large_jws_split.length)
    end

    it 'returns chunks that have string sizes of < 1191' do
      @large_jws_split.each do |chunk|
        assert_operator(1191, :>=, chunk.length)
      end
    end
   end
end
