# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < ApplicationController
  before_action :create_exporter, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: @exporter.download }
      format.fhir_json do
        fhir_params = FHIR.from_contents(request.raw_post)
        render json: @exporter.issue(fhir_params)
      end
    end
  end

  def chunks
    render json: @exporter.chunks
  end

  def scan; end

  def qr_contents
    contents = JSON.parse(params[:qr_contents])
    @jws_payload = HealthCards::Chunking.get_payload_from_qr contents
    @patient = helpers.create_patient_from_jws(@jws_payload)
  end

  private

  def create_exporter
    patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(patient)
  end
end
