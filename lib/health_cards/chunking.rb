# frozen_string_literal: true

module HealthCards
  # Split up a JWS into chunks if encoded size is above QR Code Size constraint
  module Chunking
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
  end
end