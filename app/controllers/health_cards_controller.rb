# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: health_card.to_json }
    end
  end

  def chunks
    render json: health_card.chunks.to_json
  end

  def scan; end

  def qr_contents
    contents = JSON.parse(params[:qr_contents])
    jws_payload = HealthCards::Chunking.get_payload_from_qr contents
    @patient = helpers.create_patient_from_jws(jws_payload)
    render json: JSON.pretty_generate(jws_payload) if @patient == nil
  end

  private

  def health_card
    @health_card ||= CovidHealthCard.new(@patient) do |record|
      case record
      when Patient
        fhir_patient_url(record)
      when Immunization
        fhir_immunization_url(record)
      end
    end
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end
end
