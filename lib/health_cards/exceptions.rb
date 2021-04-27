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
    def initialize(msg = 'Bundle must be a FHIR::Bundle')
      super(msg)
    end
  end

  # Exception thrown when an invalid key (public or private) is provided
  class InvalidKeyException < ArgumentError
    def initialize(expected_class, actual_obj)
      super("Expected an instance of #{expected_class} but was #{actual_obj.class}")
    end
  end
end
