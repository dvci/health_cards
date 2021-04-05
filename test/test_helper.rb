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

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    def assert_valid(model)
      model.validate
      assert_empty model.errors, model.errors.full_messages.join(', ')
    end

    def cleanup_keys
      FileUtils.rm_rf rails_key_path if File.exist?(rails_key_path)
    end

    def rails_key_path
      Rails.application.config.hc_key_path
    end

    def rails_private_key
      Rails.application.config.hc_key
    end

    def rails_public_key
      Rails.application.config.hc_key.public_key
    end

    def assert_attributes_equal(record1, record2, attr_list = nil)
      (attr_list || record1.attributes.keys).each do |attr|
        unless attr == 'id'
          assert_equal record1.send(attr), record2.send(attr),
                       "#{record1.class.name} #{attr} not the same"
        end
      end
    end
  end
end
