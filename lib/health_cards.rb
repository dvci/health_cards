# frozen_string_literal: true

require 'health_cards/version'
require 'health_cards/verifiable_credential'
require 'json/canonicalization'
require_relative 'health_cards/ext/canonicalization'

Hash.prepend HealthCards::Canonicalization

module HealthCards
  class Error < StandardError; end
  # Your code goes here...
end

data = {a: 'a', b: 'b'}
puts data.to_json_c14n