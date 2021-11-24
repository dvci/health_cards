# frozen_string_literal: true

module HealthCards
  # Represents a signed SMART Health Card
  class HealthCard
    extend Forwardable

    attr_reader :jws

    def_delegator :@qr_codes, :code_by_ordinal
    def_delegators :@payload, :bundle, :issuer

    # Create a HealthCard from a JWS
    # @param jws [JWS, String] A JWS object or JWS string
    def initialize(jws)
      @jws = JWS.from_jws(jws)
      @payload = Payload.from_payload(@jws.payload)
      @qr_codes = QRCodes.from_jws(@jws)
    end

    # Export HealthCard as JSON, formatted for file downloads
    # @return [String] JSON string containing file download contents
    def to_json(*_args)
      Exporter.file_download([@jws])
    end

    # QR Codes representing this HealthCard
    # @return [Array<Chunk>] an array of QR Code chunks
    def qr_codes
      @qr_codes.chunks
    end

    # Extracts a resource from the bundle contained in the HealthCard. A filter
    # can be applied by using a block. The method will yield each resource to the block.
    # The block should return a boolean
    # @param type [Class] :type should be a class representing a FHIR resource
    # @return The first bundle resource that matches the type and/or block evaluation
    def resource(type: nil, &block)
      resources(type: type, &block).first
    end

    # Extracts all resources from the bundle contained in the HealthCard. A filter
    # can be applied by using a block. The method will yield each resource to the block.
    # The block should return a boolean
    # @param type [Class] :type should be a class representing a FHIR resource
    # @return The first bundle resource that matches the type and/or block evaluation
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
