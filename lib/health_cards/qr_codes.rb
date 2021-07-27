# frozen_string_literal: true

require 'rqrcode'

module HealthCards
  # Implements QR Code chunking in ruby
  class QRCodes
    attr_reader :chunks

    # Creates a QRCodes from a JWS
    # @param jws [String] the JWS string
    # @return [HealthCards::QRCodes]
    def self.from_jws(jws)
      QRCodes.new(ChunkingUtils.jws_to_qr_chunks(jws.to_s))
    end

    # Creates a QRCodes from a set of encoded chunks
    # @param chunks [Array<String>] An array of QR Code chunks as a string
    def initialize(chunks)
      @chunks = chunks.sort.map.with_index(1) { |ch, i| Chunk.new(ordinal: i, input: ch) }
    end

    # Find a single QR Code chunk from this collection based on its ordinal position
    # @return [HealthCards::Chunk] A single QRCode chunk
    def code_by_ordinal(num)
      chunks.find { |ch| ch.ordinal == num }
    end

    # Combine all chunks and decodes it into a JWS object
    # @return [HealthCards::JWS] JWS object that the chunks combine to create
    def to_jws
      jws_string = ChunkingUtils.qr_chunks_to_jws(chunks.map(&:data))
      JWS.from_jws(jws_string)
    end
  end
end
