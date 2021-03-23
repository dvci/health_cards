# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient

  def show
    respond_to do |format|
      hc = CovidHealthCard.new(@patient, root_url)
      format.healthcard { render json: hc.to_json }
    end
  end

  private

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end
end
