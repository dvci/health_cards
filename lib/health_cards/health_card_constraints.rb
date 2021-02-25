# frozen_string_literal: true
require 'json'
require 'pp'


## May want to change this to constrain health cards
module HealthCardConstraints
  
  def strip_fhir_bundle(bundle)

    entries = bundle['entry']
    
    entries.each do |entry|
      url = entry['fullUrl']
      pp url


      resource = entry['resource']

      # Remove Resource.id elements
      resource.delete("id")
      # Remove Resource.meta elements
      resource.delete("meta")
      # Remove Resource.text elements
      resource.delete("text")
  
      resource.each do |element, value|
        if (value.kind_of?(Hash))

          if value.key?('coding')
            # Remove Coding.display elements
            coding = value['coding']
            coding.each do |codeableConcept|
              codeableConcept.delete('display')
            end
            # Remove CodeableConcept.text elements
            value.delete("text")
          end
          
        end


      end
        

      #pp resource
      puts 
    end

    # pp resources


    return bundle
  end

  def minify_payload
  end

  def compress_payload
  end


  def constrain_health_cards(jws_payload)
    # 
    
    
    # Strip elements
    ### If jws_payload.vx.credentialSubject.fhirBundle != null
      ######strip_elements(jws_payload)
      ### End


  end




end

include HealthCardConstraints

FILEPATH = 'fixtures/vc-c19-pcr-jwt-payload.json'
file = File.read(FILEPATH)
data_hash = JSON.parse(file)
# pp data_hash

bundle = data_hash['vc']['credentialSubject']['fhirBundle']

# pp bundle
stripped = HealthCardConstraints.strip_fhir_bundle(bundle)
# pp stripped
puts
puts 
puts



# if bundle
#   puts true
# else
#   puts false
# end

