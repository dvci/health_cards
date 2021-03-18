# frozen_string_literal: true

module HealthCards
  # Split up a JWS into chunks if encoded size is above QR Code Size constraint
  module BundleSplitting
    MAX_SINGLE_JWS_SIZE = 1195
    MAX_CHUNK_SIZE = 1191

    def split_bundle(jws)
      if jws.length <= MAX_SINGLE_JWS_SIZE
        [jws]
      else
        chunk_count = (jws.length / (MAX_CHUNK_SIZE).to_f).ceil()
        chunk_size  = (jws.length / (chunk_count).to_f).ceil()
        chunks = jws.scan(/.{1,#{chunk_size}}/)

        return chunks
      end
    end
  end
end

# include HealthCards::BundleSplitting


# FILEPATH_SMALL = 'fixtures/example-00-d-jws.txt'
# FILEPATH_LARGE = 'fixtures/example-02-d-jws.txt'

# file_data_small = File.read(FILEPATH_SMALL).split
# file_data_large = File.read(FILEPATH_LARGE).split

# small_jws = file_data_small[0]
# #large_jws = small_jws * 10
# large_jws = file_data_large[0]

# small_split = split_bundle(small_jws)
# large_split = split_bundle(large_jws)

# puts "Small JWS Payload is #{small_jws.length} characters long and is split into #{small_split.length} chunks."
# puts "Large JWS Payload is #{large_jws.length} characters long and is split into #{large_split.length} chunks."

# large_split.each do |piece|
#   puts
#   puts piece.length
#   puts 
#   puts piece
 
# end
