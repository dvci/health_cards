# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActiveSupport::TestCase
  include SearchHelper

  setup do
    @minimal_input = { patient: { given: 'John', family: 'Smith',
                                  birth_date: '10/21/1990', gender: 'male' } }
    @full_input = { patient: { given: 'Jane',
                               family: 'Smith',
                               second: 'A.',
                               suffix: 'Jr.',
                               birth_date: '11/15/2000',
                               gender: 'female',
                               phone: '800-765-4321',
                               list_id: 'I',
                               assigning_authority: 'dun',
                               identifier_type_code: 'no',
                               mother_maiden_given_name: 'Jill',
                               mother_maiden_family_name: 'Hill',
                               street_line1: '111 2nd Ave',
                               street_line2: 'Apt 3',
                               city: 'Bedford',
                               state: 'MA',
                               zip_code: '55555' } }
  end

  test 'transform hash to symbolize keys and nil empty values' do
    hash = transform_hash({ 'to' => 'sym', 'empty' => '  ' })
    assert hash.key? :to
    assert_nil hash[:empty]
  end

  test 'format patient name for QBP client' do
    correct = { given: 'Jane', family: 'Smith', second: 'A.', suffix: 'Jr.' }
    assert_equal correct, format_patient_name(@full_input[:patient])
  end

  test 'format patient list parameters for QBP client' do
    correct = { id: 'I', assigning_authority: 'dun', identifier_type_code: 'no' }
    assert_equal correct, format_patient_list(@full_input[:patient])
  end

  test 'format date of birth for QBP client' do
    assert_equal '20001511', format_dob(@full_input[:patient])
  end

  test 'format phone number for QBP client' do
    correct = { area_code: '800', local_number: '7654321' }
    assert_equal correct, format_phone_number(@full_input[:patient])
  end

  test 'format street address for QBP client' do
    assert_equal '111 2nd Ave, Apt 3', format_street_address(@full_input[:patient])
    assert_equal '111 2nd Ave', format_street_address(@full_input[:patient].reject { |k| k == :street_line2 })
    assert_nil format_street_address(@minimal_input[:patient])
  end

  test 'format address for QBP client' do
    correct = { city: 'Bedford', state: 'MA', zip: '55555', street: '111 2nd Ave, Apt 3' }
    assert_equal correct, format_address(@full_input[:patient])
  end

  test 'build minimal query for QBP client' do
    params = ActionController::Parameters.new(@minimal_input)
    params = params[:patient].permit!
    final = build_query(transform_hash(params))
    assert final
    assert final.key? :patient_name
    assert_kind_of Hash, final[:patient_name]
    assert final.key? :patient_dob
    assert_kind_of String, final[:patient_dob]
    assert final.key? :sex
    assert_kind_of String, final[:sex]
  end

  test 'build full query for QBP client' do
    params = ActionController::Parameters.new(@full_input)
    params = params[:patient].permit!
    final = build_query(transform_hash(params))
    assert final

    assert final.key? :patient_name
    assert_kind_of Hash, final[:patient_name]

    assert final.key? :patient_dob
    assert_kind_of String, final[:patient_dob]

    assert final.key? :patient_list
    assert_kind_of Hash, final[:patient_list]

    assert final.key? :mother_maiden_name
    assert_kind_of Hash, final[:mother_maiden_name]

    assert final.key? :sex
    assert_equal 'F', final[:sex]

    assert final.key? :address
    assert_kind_of Hash, final[:address]

    assert final.key? :phone
    assert_kind_of Hash, final[:phone]
  end
end
