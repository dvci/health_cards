# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    pfizer = Vaccine.find_or_create_by({ code: '208' })
    moderna = Vaccine.find_or_create_by({ code: '207' })

    birthday = 18.years.ago

    @patient1 = Patient.create!(given: 'Foo', family: 'Bar', birth_date: birthday)
    @patient1.immunizations.create!(vaccine: pfizer, occurrence: Time.zone.today - 3.weeks)
    @patient1.immunizations.create!(vaccine: pfizer, occurrence: Time.zone.today)

    patient2 = Patient.create!(given: 'Goo', family: 'Bar', birth_date: birthday)
    patient2.immunizations.create!(vaccine: moderna, occurrence: Time.zone.today - 1.week)

    # The variables below need to be updated to match IIS (maybe pull from lib/assets)
    @good_query_params = { patient: { given: @patient1.given,
                                      family: @patient1.family,
                                      birth_date: @patient1.birth_date.to_s } }

    @vague_query_params = { patient: { family: @patient1.family,
                                       birth_date: @patient1.birth_date.to_s } }
  end

  test 'should get search form' do
    get search_form_url
    assert_response :success
  end

  test 'should get search form with demo data' do
    get search_form_url, params: { 'autofill' => 'yes' }
    assert_response :success

    assert_select 'form' do
      assert_select 'input#patient_given' do |elements|
        elements.each { |element| assert_match(/\svalue="[^"]+"\s/, element.to_s) }
      end
      assert_select 'input#patient_family' do |elements|
        elements.each { |element| assert_match(/\svalue="[^"]+"\s/, element.to_s) }
      end
      assert_select 'input#patient_birth_date' do |elements|
        elements.each { |element| assert_match(/\svalue="[^"]+"\s/, element.to_s) }
      end
    end
  end

  test 'good query should redirect to found patient' do
    assert_raises(NotImplementedError) { post(search_query_url, { params: @good_query_params }) }
    # assert_redirected_to @patient1
  end

  test 'vague query params should redirect to search form' do
    assert_raises(NotImplementedError) { post(search_query_url, { params: @good_query_params.merge({ given: '' }) }) }
    # assert_redirected_to search_form_url
  end
end
