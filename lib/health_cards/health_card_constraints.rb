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


## Functionality for "Health Cards are Small section of the Smart Health Cards Specification"
module HealthCardConstraints
  
  # Remove Extraneous Fields from FHIR Bundle
  def strip_fhir_bundle(bundle)

    entries = bundle['entry']
<<<<<<< HEAD
    
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finish bundle constraints
    short_resources_flag = true
=======

>>>>>>> Link together functions of HealthCardConstraints module
    url_map = Hash.new
    resource_count = 0;

    # Bundle.entry.fullUrl should be populated with short resource-scheme URIs (e.g., {"fullUrl": "resource:0})
    entries.each do |entry|
      old_url = entry["fullUrl"]
      new_url = "Resource:#{resource_count}"

      url_map[old_url] = new_url
      entry["fullUrl"] = new_url

      resource_count += 1
    end

<<<<<<< HEAD
    entries.each do |entry|
<<<<<<< HEAD
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

=======
>>>>>>> Link together functions of HealthCardConstraints module

      resource = entry['resource']

      # Update references to match new resource-scheme URIs
      HealthCardConstraints.update_links(resource, url_map)

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

<<<<<<< HEAD
  
      

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
=======
    end
>>>>>>> Link together functions of HealthCardConstraints module
  
    return bundle
  end

  # Payload should be minified (i.e., all optional whitespace is stripped)
  def minify_payload(payload)
    minified_payload = JSON.minify(payload.to_json)
    return JSON.unparse(minified_payload) 
  end

  # Payload should be compressed with the DEFLATE (see RFC1951) algorithm before being signed (note, this should be "raw" DEFLATE compression, omitting any zlib or gz headers)
    # According to  https://gist.github.com/alazarchuk/8223772181741c4b7a7c
    # Also references https://agileweboperations.com/2008/09/15/how-inflate-and-deflate-data-ruby-and-php/
  def gzdeflate (s)
    Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(s.to_s, Zlib::FINISH)
  end

  # Reference.reference should be populated with short resource-scheme URIs (e.g., {"patient": {"reference": "resource:0"}})
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

  # Main function to operate all of the health card constraints.
  def constrain_health_cards(jws_payload)
    bundle = jws_payload['vc']['credentialSubject']['fhirBundle']
    if (bundle)
      strip_fhir_bundle(bundle)
      minify_payload(bundle)
      return Base64.encode64(gzdeflate(bundle))
    end

    return bundle
  end

end

include HealthCardConstraints

FILEPATH = 'fixtures/vc-c19-pcr-jwt-payload.json'
file = File.read(FILEPATH)
<<<<<<< HEAD
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


=======
payload = JSON.parse(file)
>>>>>>> Link together functions of HealthCardConstraints module

puts constrain_health_cards(payload)

