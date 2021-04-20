# frozen_string_literal: true

module HealthCards
  # Verifiers can validate HealthCards using public keys
  class Verifier

    class << self
      # Verify the provided Health Card
      #
      # @param health_card [HealthCards::HealthCard] the health card to verify
      # @return [Boolean] if the health card is valid
      def verify(health_card)
        # TODO: This needs better logic to make sure the public key is correct and check for key resolution
        health_card.verify
      end
    end

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
                KeySet.new
              end
    end

    # Add a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to add
    def add_keys(key)
      @keys.add_keys(key)
    end

    # Remove a key to use when verifying
    #
    # @param key [HealthCards::Key] the key to remove
    def remove_keys(key)
      @keys.remove_keys(key)
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
