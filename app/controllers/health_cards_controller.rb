# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient

  def show
    hc = CovidHealthCard.new(@patient) do |record|
      url = case record
      when Patient
        fhir_patient_url(record)
      when Immunization
        fhir_immunization_url(record)
      else
        root_url
      end
      url
    end
    
    respond_to do |format|
      format.healthcard { render json: hc.to_json }
      format.fhir_json { render json: hc.issue(request.raw_post) }
    end
  end

  private

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def health_card_params
    params.require([:resourceType, :parameter])
  end
end
