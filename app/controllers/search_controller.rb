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
    @matches = Patient.select { |x| x.match?(search_params) }

    if @matches.length.zero?
      redirect_to search_form_url, alert: 'No matches found' and return
    elsif @matches.length > 1
      redirect_to search_form_url, alert: 'Found multiple matches' and return
    else
      redirect_to @matches.first
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
end
