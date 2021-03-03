# frozen_string_literal: true
require 'json'
require 'pp'
require 'hashie'
require 'base64'
require 'zlib'
require 'json/minify'


## Functionality for "Health Cards are Small section of the Smart Health Cards Specification"
module HealthCardConstraints
  
  # Remove Extraneous Fields from FHIR Bundle
  def strip_fhir_bundle(bundle)

    entries = bundle['entry']

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

    entries.each do |entry|

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

    end
  
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
payload = JSON.parse(file)

puts constrain_health_cards(payload)

