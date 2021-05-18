# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < ApplicationController
  before_action :create_exporter, except: [:scan, :qr_contents, :upload]
  skip_before_action :verify_authenticity_token, only: [:create]
  after_action :set_cors_header, only: :create

  def show
    respond_to do |format|
      format.healthcard { render json: @exporter.download }
    end
  end

  def create
    respond_to do |format|
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
    @scan_result = HealthCards::Importer.scan(contents)
  end

  def upload
    @filename = params[:health_card].original_filename
    file = params.require(:health_card).read
    @upload_result = HealthCards::Importer.upload(file)
  end

  private

  def create_exporter
    patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(patient)
  end
end
