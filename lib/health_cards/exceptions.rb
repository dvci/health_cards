# frozen_string_literal: true

module HealthCards
  # Exception thrown when a private key is expected or required
  class MissingPrivateKey < StandardError
    def initialize(msg = 'Missing private key')
      super(msg)
    end
  end

  # Exception thrown when a public key is expected or required
  class MissingPublicKey < StandardError
    def initialize(msg = 'Missing public key')
      super(msg)
    end
  end

  # Exception thrown when an invalid payload is provided
  class InvalidPayloadException < ArgumentError
    def initialize(msg = 'Payload must be a HealthCards::VerifiableCredential')
      super(msg)
    end
  end
end
