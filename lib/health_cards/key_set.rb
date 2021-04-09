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

    # Add keys to KeySet
    #
    # Keys are added based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def add_keys(new_keys)
      if keys.is_a? KeySet
        keys.merge(new_keys)
      else
        keys.merge([*new_keys].map { |new_key| SetKey.new new_key })
      end
    end

    # Add keys to KeySet
    #
    # Keys are added based on the key thumbprint
    #
    # @param new_keys [HealthCards::Key, Array<HealthCards::Key>, HealthCards::KeySet] the initial keys
    def remove_keys(new_keys)
      if keys.is_a? KeySet
        keys.merge(new_keys)
      else
        keys.merge([*new_keys].map { |new_key| SetKey.new new_key })
      end
    end

    # Check if key is included in the KeySet
    #
    # @param key [HealthCards::Key]
    # @return [Boolean]
    delegate :include?, to: :keys
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

      # Create a new SetKey
      #
      # @param key [HealthCards::Key] the key
      def initialize(key)
        raise ArgumentError unless key.is_a? Key

        self.key = key
      end

      # @see https://ruby-doc.org/core-2.7.2/Object.html#method-i-hash
      # @see https://ruby-doc.org/stdlib-2.7.2/libdoc/set/rdoc/Set.html
      def hash
        key.thumbprint.hash
      end
    end
  end
end
