# frozen_string_literal: true

class SearchController < ApplicationController
  # include PatientHelper

  # GET /search/form
  # renders IIS consumer portal search form
  def form
    @patient = Patient.new(search_params)
  end

  # POST /search/query
  # currently searches local db only
  # will later call QBP client (TODO)
  def query
    <<-COMMENT
    @matches = Patient.select { |x| x.match?(search_params) }

    if @matches.length.zero?
      redirect_to search_form_url, alert: 'No matches found' and return
    elsif @matches.length > 1
      redirect_to search_form_url, alert: 'Found multiple matches' and return
    else
      redirect_to @matches.first
    end
    COMMENT

    results = query(search_params)

    case results[:code]
    when :AE  # Application Error
      # TODO
    when :AR  # Application Rejected
      raise StandardError.new("QBP client application rejected - QBP client should already have authorization with IIS server")
    when :NF  # No Data Found
      render 'no_data.html.erb'
    when :OK  # Data Found (No Errors)
      bundle_json = translate(results[:patient])
      
    when :PD  # Protected Data
      render 'protected.html.erb'
    when :TM  # Too Much Data Found
      redirect_to search_form_url, alert: "Too many matches found, please enter more information."
      # is there a case where one patient is found, but there are too many immunizations to load?
    else
      raise StandardError.new("QBP client code #{results[:code]} not recognized");
    end
  end

  private
  def search_params
    if params[:action] == 'form'
      params[:autofill] ? helpers.real_patient_params[:patient] : {}
    else
      params.require(:patient).permit([:given, :family, :birth_date])
    end
  end

  def query
    raise NotImplemented.new("Call QBP Client");
  end

  def translate
    raise NotImplemented.new("Call QBP Client");
  end
end
