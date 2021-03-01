# frozen_string_literal: true
require 'json'
require 'pp'
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finish bundle constraints
require 'hashie'
require 'base64'
require 'zlib'
require 'json/minify'
<<<<<<< HEAD
=======
>>>>>>> FHIR Bundle Constraints
=======
>>>>>>> Finish bundle constraints


## May want to change this to constrain health cards
module HealthCardConstraints
  
  def strip_fhir_bundle(bundle)

    entries = bundle['entry']
    
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finish bundle constraints
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


<<<<<<< HEAD
    entries.each do |entry|
      url = entry['fullUrl']
      # pp url
      

      


=======
    entries.each do |entry|
      url = entry['fullUrl']
      pp url
>>>>>>> FHIR Bundle Constraints
=======
    entries.each do |entry|
      url = entry['fullUrl']
      # pp url
      

      


>>>>>>> Finish bundle constraints


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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finish bundle constraints

  
      

      HealthCardConstraints.update_links(resource, url_map)
   


<<<<<<< HEAD
=======
>>>>>>> FHIR Bundle Constraints
=======
>>>>>>> Finish bundle constraints
        

      #pp resource
      puts 
    end

    # pp resources

<<<<<<< HEAD
<<<<<<< HEAD
  
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
=======

=======
  
>>>>>>> Finish bundle constraints
    return bundle
  end



  def minify_payload(payload)
    return JSON.minify(payload.to_json)
  end

<<<<<<< HEAD
  def compress_payload
>>>>>>> FHIR Bundle Constraints
=======
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
>>>>>>> Finish bundle constraints
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finish bundle constraints

minified = HealthCardConstraints.minify_payload(stripped)

# deflated = HealthCardConstraints.compress_payload(stripped.to_s)
deflated = Base64.encode64(gzdeflate(minified))




<<<<<<< HEAD
# pp stripped
puts
puts 
pp stripped
=======
# pp stripped
puts
puts 
puts
>>>>>>> FHIR Bundle Constraints
=======
# pp stripped
puts
puts 
pp stripped
>>>>>>> Finish bundle constraints



# if bundle
#   puts true
# else
#   puts false
# end

