# frozen_string_literal: true
require 'json'
require 'pp'
require 'hashie'
require 'base64'
require 'zlib'
require 'json/minify'


## May want to change this to constrain health cards
module HealthCardConstraints
  
  def strip_fhir_bundle(bundle)

    entries = bundle['entry']
    
    short_resources_flag = true
    url_map = Hash.new
    resource_count = 0;


    entries.each do |entry|
      old_url = entry["fullUrl"]

      new_url = "Resource:#{resource_count}"

      url_map[old_url] = new_url
      entry["fullUrl"] = new_url


      if (!(entry["fullUrl"].include? "resource"))
        short_resources_flag = false
      end
      resource_count += 1
    end
    # pp url_map


    # entries.extend Hashie::Extensions::DeepFind
    # references = entries.deep_find_all("reference")
    # if (references != nil)
    #   references.each do |reference|
    #     puts "This is my reference: #{reference}"
    #     reference = url_map[reference]
    #   end
    # end
    

    # entries.append({"new entry" => "my entry"})


    entries.each do |entry|
      url = entry['fullUrl']
      # pp url
      

      




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

  
      

      HealthCardConstraints.update_links(resource, url_map)
   


        

      #pp resource
      puts 
    end

    # pp resources

  
    return bundle
  end



  def minify_payload(payload)
    return JSON.minify(payload.to_json)
  end

  # According to  https://gist.github.com/alazarchuk/8223772181741c4b7a7c
  # Also references https://agileweboperations.com/2008/09/15/how-inflate-and-deflate-data-ruby-and-php/
  def gzdeflate (s)
    Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(s, Zlib::FINISH)
  end

  def update_links(hash, mapping)
    hash.each do |k, v|
      if k == "reference" && v.is_a?(String)
        # update link here
        if mapping.has_key?(v)
          v.replace mapping[v]
        end
      elsif v.is_a?(Hash)
        update_links(v, mapping)
      elsif v.is_a?(Array)
        v.flatten.each { |x| update_links(x, mapping) if x.is_a?(Hash) }
      end
    end
    hash
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

minified = HealthCardConstraints.minify_payload(stripped)

# deflated = HealthCardConstraints.compress_payload(stripped.to_s)
deflated = Base64.encode64(gzdeflate(minified))




# pp stripped
puts
puts 
pp stripped



# if bundle
#   puts true
# else
#   puts false
# end

