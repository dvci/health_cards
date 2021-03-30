# frozen_string_literal: true

module HealthCards
  # Split up a JWS into chunks if encoded size is above QR Code Size constraint
  module Chunking
    extend self
    MAX_SINGLE_JWS_SIZE = 1195
    MAX_CHUNK_SIZE = 1191

    def split_bundle(jws)
      if jws.length <= MAX_SINGLE_JWS_SIZE
        [jws]
      else
        chunk_count = (jws.length / MAX_CHUNK_SIZE.to_f).ceil
        chunk_size  = (jws.length / chunk_count.to_f).ceil
        jws.scan(/.{1,#{chunk_size}}/)
      end
    end

    # Splits jws into chunks and converts each string into numeric
    def generate_qr_chunks(jws)
      jws_chunks = split_bundle jws
      jws_chunks.map { |c| convert_jws_to_numeric(c) }
    end

    # Assemble jws from qr code chunks
    def assemble_jws(qr_chunks)
      if qr_chunks.length === 1
        # Strip off shc:/ and convert numeric jws
        numeric_jws = qr_chunks[0].delete_prefix('shc:/')
        jws = convert_numeric_jws numeric_jws
      end
    end

    private

    # Each character "c" of the jws is converted into a sequence of two digits by taking c.ord - 45
    def convert_jws_to_numeric(jws)
      jws.chars.map { |c| format('%02d', c.ord - 45) }.join
    end

    def convert_numeric_jws(numeric_jws)
      result_jws = ''.dup
      numeric_jws.chars.each_slice(2) do |a, b|
        result_jws << ((a + b).to_i + 45).chr
      end
      result_jws
    end
  end
end
