# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pfizer = Vaccine.create(code: '208', name: 'pfizer', doses_required: 2)
    @moderna = Vaccine.create(code: '207', name: 'moderna', doses_required: 2)

    @birthday = 18.years.ago

    $patient1 = Patient.create(given: 'Foo', family: 'Bar', birth_date: @birthday)
    $patient1.immunizations.create(vaccine: @pfizer, occurrence: Time.zone.today - 3.weeks)
    $patient1.immunizations.create(vaccine: @pfizer, occurrence: Time.zone.today)

    @patient2 = Patient.create(given: 'Goo', family: 'Bar', birth_date: @birthday)
    @patient2.immunizations.create(vaccine: @moderna, occurrence: Time.zone.today - 1.week)
  end

  good_query_params = { patient: { given: $patient1.given, family: $patient1.family, birth_date: $birthday } }
  no_query_params = { patient: {} }
  vague_query_params = { patient: { family: 'Bar' } }

  test 'should get search form' do
    get search_form_url
    assert_response :success
  end

  test 'should get search form with demo data' do
    get search_form_url, params: { 'autofill' => 'yes' }
    assert_response :success
    assert_select 'form input' do
      assert_select '#patient_given[value=?]', /.+/
      assert_select '#patient_family[value=?]', /.+/
      assert_select '#patient_birth_date[value=?]', /.+/
    end
  end

  test 'good query should redirect to found patient' do
    post search_query_url, { params: good_query_params }
    assert_redirected_to $patient1
  end

  test 'no query params should redirect to search form' do
    post search_query_url, { params: no_query_params }
    assert_redirected_to search_form_url
  end

  test 'vague query params should redirect to search form' do
    post search_query_url, { params: vague_query_params }
    assert_redirected_to search_form_url
  end
end
