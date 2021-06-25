# frozen_string_literal: true

module HealthCards
  # Handles behavior related to removing disallowed attributes from FHIR Resources
  module AttributeFilters
    def self.included(base)
      base.extend ClassMethods
    end

    # Class level methods for HealthCard class specific settings
    module ClassMethods
      # Define allowed attributes for this HealthCard class
      # @param type [Class] Scopes the attributes to a spefic class. Must be a subclass of FHIR::Model
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def allow(type: nil, attributes: [])
        raise ArgumentError, 'Must specify a base type for allowable attributes' if type.nil?

        allowable[type] = attributes
      end

      # Define disallowed attributes for this HealthCard class
      # @param type [Class] Scopes the attributes to a spefic class. If not used will default to all FHIR resources.
      # To apply a rule to all FHIR types (resources and types), use FHIR::Model as the type
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def disallow(type: nil, attributes: [])
        disallowable[type] ||= []
        disallowable[type].concat(attributes)
      end

      # Define disallowed attributes for this HealthCard class
      # @return [Hash] A hash of FHIR::Model subclasses and attributes that will pass through minimization
      def disallowable
        return @disallowable if @disallowable

        @disallowable = parent_disallowables
      end

      # Define allowed attributes for this HealthCard class
      # @return [Hash] A hash of FHIR::Model subclasses and attributes that will pass through minimization
      def allowable
        return @allowable if @allowable

        @allowable = parent_allowables
      end

      protected

      def parent_allowables(base = {})
        self < HealthCards::HealthCard ? base.merge(superclass.allowable) : base
      end

      def parent_disallowables(base = {})
        self < HealthCards::HealthCard ? base.merge(superclass.disallowable) : base
      end
    end

    def handle_allowable(resource)
      class_allowables = self.class.allowable[resource.class]

      return unless class_allowables

      allowed = resource.to_hash.select! { |att| class_allowables.include?(att) }

      resource.from_hash(allowed)
    end

    def handle_disallowable(resource)
      class_disallowable = find_subclass_keys(self.class.disallowable, resource)

      return if class_disallowable.empty?

      all_disallowed = class_disallowable.map do |disallowed_class|
        self.class.disallowable[disallowed_class]
      end.flatten.uniq

      allowed = resource.to_hash.delete_if { |att| all_disallowed.include?(att) }

      resource.from_hash(allowed)
    end

    protected

    def find_subclass_keys(hash, resource)
      subclasses = hash.keys.compact.filter { |class_key| resource.class <= class_key }
      # No great way to determine if this is an actual FHIR resource
      subclasses << nil if resource.respond_to?(:resourceType)
      subclasses
    end
  end
end
