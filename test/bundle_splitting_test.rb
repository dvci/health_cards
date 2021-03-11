# frozen_string_literal: true

require 'test_helper'

FILEPATH_SMALL = 'fixtures/example-00-d-jws.txt'

describe HealthCards do
  before do
    @small_jws = File.read(FILEPATH_SMALL).split[0]
  end

  describe 'when a jws of size <= 1195 is passed into the bundle splitter' do
    it 'returns only 1 chunk' do
    end
  end

  # describe 'when a jws of size >= 1190 is passed into the bundle splitter' do
  #   before do
  #     ## Later actually import the large one and move the big to do to the smaller describe
  #     @large_jws = @small_jws * 10
  #   end

  #   it 'returns multiple chunks if the string size is > 1195' do
  #   end
  #   it 'returns chunks that have string sizes of < 1191' do
  #  end
end

# FILEPATH_SMALL = 'fixtures/example-00-d-jws.txt'

# file_data = File.read(FILEPATH_SMALL).split

# small_jws = file_data[0]
# large_jws = small_jws * 10

# small_split = split_bundle(small_jws)
# large_split = split_bundle(large_jws)

# puts "Small JWS Payload is #{small_jws.length} characters long and is split into #{small_split.length} chunks."
# puts "Large JWS Payload is #{large_jws.length} characters long and is split into #{large_split.length} chunks."
