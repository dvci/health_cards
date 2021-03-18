# frozen_string_literal: true

require 'json'
require 'base64'
require 'zlib'
#require 'json/minify'

module HealthCards
  ## Functionality for "Health Cards are Small" section of the Smart Health Cards Specification
  module HealthCardConstraints
    def strip_fhir_bundle(bundle)
      entries = bundle['entry']
      entries, url_map = update_uris(entries)
      strip_resource_elements(entries, url_map)

      bundle
    end

    def update_uris(resources)
      url_map = {}
      resource_count = 0

      resources.each do |entry|
        old_url = entry['fullUrl']
        new_url = "Resource:#{resource_count}"

        url_map[old_url] = new_url
        entry['fullUrl'] = new_url

        resource_count += 1
      end

      [resources, url_map]
    end

    def strip_resource_elements(resources, url_map)
      resources.each do |entry|
        resource = entry['resource']

        update_links(resource, url_map)

        resource.delete('id')
        resource.delete('meta')
        resource.delete('text')

        resource.each do |_element, value|
          next unless value.is_a?(Hash) && value.key?('coding')

          coding = value['coding']
          coding.each do |codeable_concept|
            codeable_concept.delete('display')
          end
          value.delete('text')
        end
      end

      resources
    end

    def minify_payload(payload)
      minified_payload = JSON.minify(payload.to_json)
      JSON.unparse(minified_payload)
    end

    # According to  https://gist.github.com/alazarchuk/8223772181741c4b7a7c
    # Also references https://agileweboperations.com/2008/09/15/how-inflate-and-deflate-data-ruby-and-php/
    def gzdeflate(payload)
      Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(payload.to_s, Zlib::FINISH)
    end

    def update_links(hash, mapping) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      hash.each do |k, v|
        if k == 'reference' && v.is_a?(String)
          v.replace mapping[v] if mapping.key?(v)
        elsif v.is_a?(Hash)
          update_links(v, mapping)
        elsif v.is_a?(Array)
          v.flatten.each { |x| update_links(x, mapping) if x.is_a?(Hash) }
        end
      end
      hash
    end

    def delete_key(hash, mapping) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      hash.each do |k, v|
        if k == 'reference' && v.is_a?(String)
          v.replace mapping[v] if mapping.key?(v)
        elsif v.is_a?(Hash)
          update_links(v, mapping)
        elsif v.is_a?(Array)
          v.flatten.each { |x| update_links(x, mapping) if x.is_a?(Hash) }
        end
      end
      hash
    end

    def constrain_health_cards(jws_payload)
      bundle = jws_payload['vc']['credentialSubject']['fhirBundle']
      if bundle
        strip_fhir_bundle(bundle)
        pp bundle
        minify_payload(bundle)
        return Base64.encode64(gzdeflate(bundle))
      end

      bundle
    end
  end
end

# include HealthCards::HealthCardConstraints

# FILEPATH = 'fixtures/vc-c19-pcr-jwt-payload.json'
# file = File.read(FILEPATH)
# payload = JSON.parse(file)

# constrain_health_cards(payload)
# # puts constrain_health_cards(payload)
