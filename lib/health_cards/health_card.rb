# frozen_string_literal: true

module HealthCards
  # Represents a signed SMART Health Card
  class HealthCard
    extend Forwardable

    attr_reader :jws

    def_delegator :@jws, :verify
    def_delegator :@qr_codes, :code_by_ordinal
    def_delegators :@payload, :bundle, :issuer

    def initialize(jws)
      @jws = jws.is_a?(String) ? JWS.from_jws(jws) : jws
      @payload = Payload.from_payload(@jws.payload)
      @qr_codes = QRCodes.from_jws(@jws)
    end

    def credential
      { verifiableCredential: [@jws.to_s] }
    end

    def to_json(*_args)
      credential.to_json
    end

    def qr_codes
      @qr_codes.chunks
    end

    def resource(type: nil, &block)
      resources(type: type, &block).first
    end

    def resources(type: nil, &block)
      all_resources = bundle.entry.map(&:resource)
      return all_resources unless type || block

      all_resources.filter do |r|
        resource_matches_criteria(r, type, &block)
      end
    end

    private

    def resource_matches_criteria(resource, type, &block)
      of_type = type && resource.is_a?(type)
      if block && type
        of_type && yield(resource)
      elsif !type && block
        yield(resource)
      else
        of_type
      end
    end
  end
end
