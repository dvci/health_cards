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

    def key_for_card(card)
      self.keys
    end

    # Verify a HealthCard
    #
    # @param health_card [HealthCards::HealthCard, HealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def verify(health_card)
      # TODO: This needs better logic to make sure the public key is correct and check for key resolution
      card = case health_card
      when HealthCard
        health_card
      when JWS
        health_card
      when String
        card_from_jws_string(health_card)
      else
        raise ArgumentError.new("Expected either a HealthCards::HealthCard, HealthCards::JWS or String")
      end
      
      card.verify
    end

    private

    def card_from_jws_string(card)
      new_card = HealthCard.from_jws(card)
      key = keys.find_key(new_card.thumbprint)
      raise MissingPublicKey.new unless key
      new_card.public_key = key
      new_card
    end
  end
end
