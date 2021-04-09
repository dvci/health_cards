# frozen_string_literal: true

module HealthCards
  # Exception thrown when a private key is expected or required
  class MissingPrivateKey < StandardError
    def initialize(msg = 'Missing private key')
      super(msg)
    end
  end
end
