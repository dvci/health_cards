# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'health_cards'

require 'minitest/autorun'
require 'minitest/spec'
