# frozen_string_literal: true
<<<<<<< HEAD
require 'json'
require 'pp'
require 'hashie'

## May want to change this to constrain health cards
module BundleSplitting
  def splitBundle(payload, header_size = 54, signature_size = 95)
    max_payload_size = 1195 - header_size - signature_size
    payload
  end

end


include BundleSplitting

FILEPATH = 'fixtures/vc-c19-pcr-jwt-payload.json'
file = File.read(FILEPATH)
data_hash = JSON.parse(file)
# pp data_hash

bundle = data_hash['vc']['credentialSubject']['fhirBundle']

# pp bundle
stripped = BundleSplitting.splitBundle(bundle)

pp stripped


=======

## May want to change this to constrain health cards
module BundleSplitting


end
>>>>>>> FHIR Bundle Constraints
