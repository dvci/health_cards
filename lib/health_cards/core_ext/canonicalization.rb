# frozen_string_literal: true

module HealthCards
  module CoreExt
    # method to json canonicalize ruby object
    module Canonicalization
      def to_json_c14n
        canonicalized = keys.sort_by { |k| k.to_s.encode(Encoding::UTF_16) }
                            .map { |k| "#{k.to_s.to_json_c14n}:#{self[k].to_json_c14n}" }
                            .join(',')
        "{#{canonicalized}}"
      end
    end
  end
end
