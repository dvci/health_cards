# frozen_string_literal: true

module HealthCards
  # Allows users to put an arbitrary bundle into a HealthCard and have HealthCard
  # extract relevant data from it
  module BundleFilters
    include AttributeFilters

    Slice = Struct.new(:name, :type, :collection)

    def self.included(base)
      base.extend ClassMethods
    end

    # Class methods to define bundle membership
    module ClassMethods
      def bundle_member(attribute_name, type:)
        slices << Slice.new(attribute_name, type, false)
        define_method attribute_name do
          instance_variable_get("@#{attribute_name}")
        end
      end

      def bundle_collection(attribute_name, type:)
        slices << Slice.new(attribute_name, type, true)
        define_method attribute_name do
          instance_variable_get("@#{attribute_name}")
        end
      end

      def slices
        @slices ||= []
      end

      def parent_slices(base = [])
        self < HealthCards::HealthCard ? base.concat(superclass.slices) : base
      end
    end

    def extract_bundle(bundle)
      return bundle if self.class.slices.empty?

      entries_by_type = bundle.entry.group_by { |entry| entry.resource.class }

      self.class.slices.each_with_object(FHIR::Bundle.new(type: 'collection')) do |slice, new_bundle|
        if slice.collection
          collection = entries_by_type[slice.type]
          new_bundle.entry.concat(collection) if collection
          instance_variable_set("@#{slice.name}", collection)
        else
          member = entries_by_type[slice.type]&.first
          new_bundle.entry << member if member
          instance_variable_set("@#{slice.name}", member)
        end
      end
    end

  end
end
