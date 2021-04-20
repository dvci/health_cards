# frozen_string_literal: true

module HealthCards
  # A set of keys used for signing or verifying HealthCards
  class KeySet

    # Create a new KeySet
    #
    # @param keys [HealthCards::Key, Array<HealthCards::Key>, nil] the initial keys
    def initialize(keys = nil)
      add_keys(keys) unless keys.nil?
    end

    # The contained keys
    #
    # @return [Set]
    def keys
      @keys ||= Set.new
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
      keys.find { |key| key.hash == thumbprint.hash }&.key
    end

    # Add keys to KeySet
    #
    # Keys are added based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def add_keys(new_keys)
      if new_keys.is_a? KeySet
        keys.merge(new_keys.keys)
      else
        keys.merge([*new_keys].map { |new_key| SetKey.new new_key })
      end
    end

    # Remove keys from KeySet
    #
    # Keys are remove based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def remove_keys(new_keys)
      if new_keys.is_a? KeySet
        keys.subtract(new_keys.keys)
      else
        keys.subtract([*new_keys].map { |new_key| SetKey.new new_key })
      end
    end

    # Check if key is included in the KeySet
    #
    # @param key [HealthCards::Key]
    # @return [Boolean]
    def include?(key)
      keys.include?(SetKey.new(key))  
    end

    delegate :empty?, to: :keys

    # Container class for keys in the key set
    #
    # This class reimplements the `#hash` method so that Equality of elements is determined based
    # on the key thumbprint.
    #
    # https://ruby-doc.org/stdlib-2.7.2/libdoc/set/rdoc/Set.html
    # https://stackoverflow.com/questions/53399306/how-does-set-in-ruby-compare-elements
    class SetKey

      attr_reader :key

      delegate :to_jwk, to: :key

      # Create a new SetKey
      #
      # @param key [HealthCards::Key] the key
      def initialize(key)
        raise ArgumentError unless key.is_a? Key

        @key = key
      end

      def eql?(other)
        self.hash == other.hash
      end

      # @see https://ruby-doc.org/core-2.7.2/Object.html#method-i-hash
      # @see https://ruby-doc.org/stdlib-2.7.2/libdoc/set/rdoc/Set.html
      def hash
        key.thumbprint.hash
      end
    end
  end
end
