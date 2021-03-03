# frozen_string_literal: true

module BundleSplitting
  MAX_SINGLE_JWS_SIZE = 1195
  MAX_CHUNK_SIZE = 1191

  def splitBundle(jws) 
    if (jws.length <= MAX_SINGLE_JWS_SIZE)
      return [jws]
    else
      chunks = []
      i = 0
      number_of_chunks = jws.length / MAX_CHUNK_SIZE

      while (i < number_of_chunks)
        chunks.push(jws.slice(i * MAX_CHUNK_SIZE, (i + 1) * MAX_CHUNK_SIZE))
        i += 1 
      end

      return chunks
      
    end
  end

end


include BundleSplitting

FILEPATH_SMALL = 'fixtures/example-00-d-jws.txt'

file_data = File.read(FILEPATH_SMALL).split

small_jws = file_data[0]
large_jws = small_jws * 10

puts small_jws.length
puts large_jws.length


split = BundleSplitting.splitBundle(large_jws)

puts split.length
