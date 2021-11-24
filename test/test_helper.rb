# frozen_string_literal: true

require 'simplecov'
require 'webmock/minitest'
require 'json'

SimpleCov.start do
  enable_coverage :branch
  add_filter '/test/'
  add_filter '/config/'
end

if ENV['GITHUB_ACTIONS']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
FHIR.logger = Rails.logger

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

    def rails_issuer
      Rails.application.config.issuer
    end

    def assert_attributes_equal(record1, record2, attr_list = nil)
      (attr_list || record1.attributes.keys).each do |attr|
        unless attr == 'id'
          assert_equal record1.send(attr), record2.send(attr),
                       "#{record1.class.name} #{attr} not the same"
        end
      end
    end

    def load_json_fixture(file_name)
      JSON.decode(File.read("test/fixtures/files/#{file_name}.json"))
    end

    ## Refactor test-helpers
    def private_key
      HealthCards::PrivateKey.generate_key
    end

    def bundle_payload
      bundle = FHIR::Bundle.new(type: 'collection')
      bundle.entry << FHIR::Bundle::Entry.new(fullUrl: 'http://patient/1', resource: FHIR::Patient.new)
      bundle
    end

    def assert_fhir(obj, type: nil, validate: true)
      output = FHIR.from_contents(obj)
      assert output.is_a?(type) if type
      assert output.valid?, output.validate if validate
      output
    end

    def assert_operation_outcome(response, response_code: :not_found)
      assert_fhir(response.body, type: FHIR::OperationOutcome)
      assert_response response_code
    end

    def assert_entry_references_match(patient_entry, reference_element)
      patient_url = patient_entry.fullUrl
      ref_url = reference_element.reference

      assert_not_nil patient_url
      assert_equal patient_url, ref_url
    end

    def assert_jws_bundle_match(jws, _key, patient_entry, vax_entry)
      card = nil

      assert_nothing_raised do
        card = HealthCards::HealthCard.new(jws)
      end

      entries = card.bundle.entry

      patient = entries[0].resource
      assert patient.valid?
      assert_equal patient_entry.given, patient.name[0].given[0]

      imm = entries[1].resource

      # Deactivated until spec or FHIR validator is updated
      # assert imm.valid?

      assert_equal vax_entry.code, imm.vaccineCode.coding[0].code
    end
  end
end
