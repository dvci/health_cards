# frozen_string_literal: true
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
require 'json'
require 'pp'
require 'hashie'
=======
>>>>>>> Implement new bundle splitting approach

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


<<<<<<< HEAD
=======
=======
require 'json'
require 'pp'
require 'hashie'
>>>>>>> Finish bundle constraints

## May want to change this to constrain health cards
module BundleSplitting
  def splitBundle(payload, header_size = 54, signature_size = 95)
    max_payload_size = 1195 - header_size - signature_size
    payload
  end

end
<<<<<<< HEAD
>>>>>>> FHIR Bundle Constraints
=======


include BundleSplitting

FILEPATH = 'fixtures/vc-c19-pcr-jwt-payload.json'
file = File.read(FILEPATH)
data_hash = JSON.parse(file)
# pp data_hash

bundle = data_hash['vc']['credentialSubject']['fhirBundle']

# pp bundle
stripped = BundleSplitting.splitBundle(bundle)

pp stripped


>>>>>>> Finish bundle constraints
=======
split = BundleSplitting.splitBundle(large_jws)

puts split.length
>>>>>>> Implement new bundle splitting approach
