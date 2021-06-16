# frozen_string_literal: true

module HealthCards
  # Handles behavior related to removing disallowed attributes from FHIR Resources
  module AttributeFilters
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    # Class level methods for HealthCard class specific settings
    module ClassMethods
      # Define allowed attributes for this HealthCard class
      # @param klass [Class] Scopes the attributes to a spefic class. Must be a subclass of FHIR::Model
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def allow(type: FHIR::Model, attributes: [])
        allowable[type] = attributes
      end

      # Define disallowed attributes for this HealthCard class
      # @param klass [Class] Scopes the attributes to a spefic class. Must be a subclass of FHIR::Model
      # @param attributes [Array] An array of string with the attribute names that will be passed through
      #  when data is minimized
      def disallow(type: FHIR::Model, attributes: [])
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

    # Disallow attributes on resource instances
    module InstanceMethods
      def handle_allowable(resource)
        # byebug if resource.is_a?(FHIR::Patient)
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
        hash.keys.filter { |class_key| resource.class <= class_key }
      end
    end
  end
end
