# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient

  def show
    respond_to do |format|
      format.healthcard { render json: health_card.to_json }
    end
  end

  def chunks
    respond_to do |format|
      format.json { render json: health_card.chunks.to_json }
    end
  end

  private

  def health_card
    @covid_health_card ||= CovidHealthCard.new(@patient) do |record|
      case record
      when Patient
        patient_url(record)
      when Immunization
        immunization_url(record)
      end
    end
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end
end
