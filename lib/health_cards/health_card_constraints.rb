# frozen_string_literal: true

require 'base64'
require 'zlib'
require 'json/minify'

module HealthCards
  ## Functionality for "Health Cards are Small" section of the Smart Health Cards Specification
  module HealthCardConstraints
    def bundle_operations(payload)
      bundle = payload['vc']['credentialSubject']['fhirBundle']
      if bundle
        entries = bundle['entry']
        entries, url_map = redefine_uris(entries)

        update_elements(entries, url_map)
      end
      payload
    end

    def redefine_uris(resources)
      url_map = {}
      resource_count = 0

      resources.each do |entry|
        old_url = entry['fullUrl']
        new_url = "resource:#{resource_count}"

        url_map[old_url] = new_url
        entry['fullUrl'] = new_url

        resource_count += 1
      end

      [resources, url_map]
    end

    def update_elements(resources, url_map)
      resources.each do |entry|
        resource = entry['resource']

        resource.delete('id')
        resource.delete('meta')
        resource.delete('text')
        update_nested_elements(resource, url_map)
      end
      resources
    end

    def update_nested_elements(hash, url_map) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      hash.each do |k, v|
        if v.is_a?(Hash) && (k.include?('CodeableConcept') || v.key?('coding'))
          v.delete('text')
        elsif k == 'coding'
          v.each do |coding|
            coding.delete('display')
          end
        elsif k == 'reference' && v.is_a?(String)
          v.replace url_map[v] if url_map.key?(v)
        end

        case v
        when Hash
          update_nested_elements(v, url_map)
        when Array
          v.flatten.each { |x| update_nested_elements(x, url_map) if x.is_a?(Hash) }
        end
      end
      hash
    end

    def minify_payload(payload)
      JSON.minify(payload.to_json)
    end

    # According to  https://gist.github.com/alazarchuk/8223772181741c4b7a7c
    # Also references https://agileweboperations.com/2008/09/15/how-inflate-and-deflate-data-ruby-and-php/
    def compress_payload(payload)
      deflated = Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(payload.to_s, Zlib::FINISH)
      Base64.encode64(deflated)
    end

    def constrain_health_cards(jws_payload)
      stripped_bundle_payload = bundle_operations(jws_payload)
      minified_payload = minify_payload(stripped_bundle_payload)
      compress_payload(minified_payload)
    end
  end
end
