# frozen_string_literal: true

module HealthCards
  # Verifiers can validate HealthCards using public keys
  class Verifier

    attr_reader :keys

    # Create a new Verifier
    #
    # @param keys [HealthCards::KeySet, HealthCards::Key, nil]
    def initialize(keys: nil)
      @keys = case keys
              when KeySet
                keys
              when Key
                KeySet.new(keys)
              else
                raise ArgumentError
              end
    end

    # Add a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to add
    def add_key(key)
      @keys.add_key(key)
    end

    # Remove a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to remove
    def remove_key(key)
      @keys.remove_key(key)
    end

    # Verify a HealthCard
    #
    # @param health_card [HealthCards::HealthCard] the health card to verify
    def verify(health_card)
      # TODO: This needs better logic to make sure the public key is correct and check for key resolution
      health_card.verify
    end
  end
end
