# frozen_string_literal: true

module HealthCards
  # Exception thrown when a public key is expected or required
  class MissingPublicKey < StandardError
    def initialize(msg = 'Missing public key')
      super(msg)
    end
  end
end
