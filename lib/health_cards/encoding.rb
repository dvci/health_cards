# frozen_string_literal: true

module HealthCards
  # Encoding utilities for producing JWS
  #
  # @see https://datatracker.ietf.org/doc/html/rfc7515#appendix-A.3.1
  module Encoding
    # Encodes the provided data using url safe base64 without padding
    # @param data [String] the data to be encoded
    # @return [String] the encoded data
    def encode(data)
      Base64.urlsafe_encode64(data, padding: false).gsub("\n", '')
    end

    # Decodes the provided data using url safe base 64
    # @param data [String] the data to be decoded
    # @return [String] the decoded data
    def decode(data)
      Base64.urlsafe_decode64(data)
    end
  end
end
