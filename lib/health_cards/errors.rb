# frozen_string_literal: true

module HealthCards
  class HealthCardsError < StandardError; end

  class JWSError < HealthCardsError; end

  class HealthCardError < HealthCardsError; end

  #  Errors related to JWS

  # Exception thrown when a private key is expected or required
  class MissingPrivateKeyError < JWSError
    def initialize(msg = 'Missing private key')
      super(msg)
    end
  end

  # Exception thrown when a public key is expected or required
  class MissingPublicKeyError < JWSError
    def initialize(msg = 'Missing public key')
      super(msg)
    end
  end

  class UnresolvableKeySetError < JWSError; end

  # Errors related to Payload / Bundle

  # Exception thrown when an invalid payload is provided
  class InvalidPayloadError < HealthCardError
    def initialize(msg = 'Bundle is not a valid FHIR Bundle')
      super(msg)
    end
  end

  # Exception thrown when verifiable credential JSON does not include a locatable FHIR Bundle
  class InvalidCredentialError < HealthCardError
    def initialize(msg = 'Unable to locate FHIR Bundle in credential')
      super(msg)
    end
  end

  # Exception thrown when a reference in a bundle in unresolvable
  class InvalidBundleReferenceError < HealthCardError
    def initialize(url)
      super("Unable to resolve url (#{url}) within bundle")
    end
  end

  # Error thrown when FHIR Parameters are invalid
  class InvalidParametersError < HealthCardError
    attr_reader :code

    def initialize(code: nil, message: nil)
      @code = code
      super(message)
    end
  end

  # Other errors

  # Exception thrown when an invalid key (public or private) is provided
  class InvalidKeyError < HealthCardsError
    def initialize(expected_class, actual_obj)
      super("Expected an instance of #{expected_class} but was #{actual_obj.class}")
    end
  end
end
