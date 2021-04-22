# frozen_string_literal: true

module HealthCards
  # A set of keys used for signing or verifying HealthCards
  class KeySet
    # Create a new KeySet
    #
    # @param keys [HealthCards::Key, Array<HealthCards::Key>, nil] the initial keys
    def initialize(keys = nil)
      @key_map = {}
      add_keys(keys) unless keys.nil?
    end

    # The contained keys
    #
    # @return [Array]
    def keys
      @key_map.values
    end

    # Returns the keys as a JWK
    #
    # @return
    def to_jwk
      { keys: keys.map(&:to_jwk) }.to_json
    end

    # Retrieves a key from the keyset with a thumbprint
    # that matches the parameter
    # @param thumbprint [String] a Base64 encoded thumbprint from a JWS or Key
    # @return [HealthCard::Key] a key with a matching thumbprint or nil if not found
    def find_key(thumbprint)
      @key_map[thumbprint]
    end

    # Add keys to KeySet
    #
    # Keys are added based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def add_keys(new_keys)
      if new_keys.is_a? KeySet
        add_keys(new_keys.keys)
      else
        [*new_keys].each { |new_key| @key_map[new_key.thumbprint] = new_key }
      end
    end

    # Remove keys from KeySet
    #
    # Keys are remove based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def remove_keys(removed_keys)
      if removed_keys.is_a? KeySet
        remove_keys(removed_keys.keys)
      else
        [*removed_keys].each { |removed_key| @key_map.delete(removed_key.thumbprint) }
      end
    end

    # Check if key is included in the KeySet
    #
    # @param key [HealthCards::Key]
    # @return [Boolean]
    def include?(key)
      !@key_map[key.thumbprint].nil?
    end

    delegate :empty?, to: :keys
  end
end
