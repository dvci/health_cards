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
      qr_codes.chunks
    end

    def resource(type:, &block)
      resources(type: type, &block).first
    end

    def resources(type: nil,  &block)
      return bundle.entry.map(&:resource) unless type || block

      type ? bundle.filter { |_e| entry.resource.is_a?(type) } : bundle.filter { |e| yield(e.resource) }
    end
  end
end
