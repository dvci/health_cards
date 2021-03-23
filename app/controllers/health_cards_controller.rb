# frozen_string_literal: true

class HealthCardsController < ApplicationController

  before_action :find_patient

  def show
    respond_to do |format|
      hc = CovidHealthCard.new(@patient, root_url)
      format.healthcard { render json: { verifiableCredential: [hc.jwt] } }
    end
  end

  private

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end
end
