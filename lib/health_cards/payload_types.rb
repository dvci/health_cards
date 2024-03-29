# frozen_string_literal: true

module HealthCards
  # Handles behavior related to support types by Payload subclasses
  module PayloadTypes
    # Additional type claims this Payload class supports
    # @param types [String, Array] A string or array of string representing the additional type claims or nil
    # if used as a getter
    # @return [Array] the additional types added by this classes
    def additional_types(*add_types)
      @additional_types ||= []
      @additional_types.concat(add_types) unless add_types.nil?
      @additional_types
    end

    # Type claims supported by this Payload subclass
    # @return [Array] an array of Strings with all the supported type claims
    def types
      @types ||= self == HealthCards::Payload ? additional_types : superclass.types + additional_types
    end

    # Check if this class supports the given type claim(s)
    # @param type [Array, String] A type as defined by the SMART Health Cards framework
    # @return [Boolean] Whether or not the type param is included in the types supported by the Payload (sub)class
    def supports_type?(*type)
      !types.intersection(type.flatten).empty?
    end
  end
end
