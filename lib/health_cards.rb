# frozen_string_literal: true

require 'health_cards/version'
require 'health_cards/verifiable_credential'
require 'json/canonicalization'
require_relative 'health_cards/core_ext/canonicalization'

# Add support for symbol keys
Hash.prepend HealthCards::CoreExt::Canonicalization

module HealthCards
  class Error < StandardError; end
  # Your code goes here...
end