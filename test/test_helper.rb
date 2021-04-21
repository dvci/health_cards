# frozen_string_literal: true

require 'simplecov'
require 'webmock/minitest'

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

    ## Refactor test-helpers
    def private_key
      HealthCards::PrivateKey.generate_key
    end

    def vc
      HealthCards::VerifiableCredential.new("http://example.com", bundle_payload)
    end

    def bundle_payload
      bundle = FHIR::Bundle.new
      bundle.entry << FHIR::Bundle::Entry.new(resource: FHIR::Patient.new)
      bundle
    end
  end
end
