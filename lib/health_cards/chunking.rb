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
      chunks = split_bundle(jws.to_s).map { |c| convert_jws_to_numeric(c) }

      # if 1 chunk, attach prefix shc:/
      # if multiple chunks, attach prefix shc:/$orderNumber/$totalChunkCount
      if chunks.length == 1
        chunks[0] = "shc:/#{chunks[0]}"
      else
        chunks.each_with_index do |ch, i|
          chunks[i] = "shc:/#{i + 1}/#{chunks.length}/#{ch}"
        end
      end
      chunks
    end

    # Assemble jws from qr code chunks
    def assemble_jws(qr_chunks)
      if qr_chunks.length == 1
        # Strip off shc:/ and convert numeric jws
        numeric_jws = qr_chunks[0].delete_prefix('shc:/')
        convert_numeric_jws numeric_jws
      else
        ordered_qr_chunks = strip_prefix_and_sort qr_chunks
        ordered_qr_chunks.map { |c| convert_numeric_jws(c) }.join
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

    def strip_prefix_and_sort(qr_chunks)
      # Multiple QR codes are prefixed with 'shc:/C/N' where C is the index and N is the total number of chunks
      # Sorts chunks by C
      sorted_chunks = qr_chunks.sort_by { |c| c[%r{/(.*?)/}, 1].to_i }
      # Strip prefix
      sorted_chunks.map { |c| c.sub(%r{shc:/(.*?)/(.*?)/}, '') }
    end
  end
end
