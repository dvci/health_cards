# frozen_string_literal: true

class SearchController < ApplicationController
  # GET /search/form
  def form
    @patient = Patient.new(patient_params)
  end

  # POST /search/query
  def query
    results = qbp_query(query_params)

    case results[:code]
    when 'AE'
      redirect_to search_form_url,
                  alert: 'Sorry there was an error, please try again. If problem persists contact system administrator.'
    when 'AR'
      render 'rejected', status: :bad_request
    when 'NF'
      render 'no_data'
    when 'OK'
      json_bundle = translate(results[:patient])
      # TODO: - validation here
      render_patient(json_bundle)
    when 'PD'
      render 'protected', status: :forbidden
    when 'TM'
      redirect_to search_form_url, alert: 'Too many matches found, please enter more information.'
    else
      raise StandardError, "QBP client code #{results[:code]} not recognized"
    end
  end

  private

  # only for search#form
  def patient_params
    params[:autofill] ? helpers.iis_patient_params[:patient] : {}
  end

  # only for search#query
  def query_params
    hash = helpers.sanitize_input(params)
    hash = helpers.transform_hash(hash)
    helpers.build_query(hash)
  end

  def render_patient(json)
    @patient = Patient.create_from_bundle!(json)
  rescue ActiveRecord::RecordInvalid
    redirect_to(search_form_url,
                { alert: 'Information from IIS could not be validated.' })
  rescue ActiveRecord::RecordNotSaved
    redirect_to(search_form_url,
                { alert: 'Patient record could not be saved and rendered.' })
  else
    redirect_to(@patient)
  end

  # from qbp-client branch
  def qbp_query(query_hash)
    return params[:qbp_response] if Rails.env.test? && params[:qbp_response]
  
    # QBPClient.query( query_hash )
    raise NotImplementedError, "Calling QBP Client w/ parameter: #{query_hash}"
  end

  # from qbp-client branch
  def translate(hl7v2_text)
    # QBPClient.translate(hl7v2_text)
    raise NotImplementedError, "Calling QBP Client w/ parameter: #{hl7v2_text}" unless Rails.env.test?

    hl7v2_text # pass through results[:patient] for testing
  end
end
