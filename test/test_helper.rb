# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/test/'
  add_filter '/config/'
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

ActiveRecord::Base.logger.level = 1
Rails.logger.level = 1

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    def assert_attributes_equal(record1, record2, attr_list=nil)
      (attr_list || record1.attributes.keys).each do |attr|
        assert_equal record1.send(attr), record2.send(attr), "#{record1.class.name} #{attr} not the same" unless attr == 'id'
      end
    end
  end
end
