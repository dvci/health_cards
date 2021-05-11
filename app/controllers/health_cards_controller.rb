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
      format.fhir_json do
        @fhir_params = FHIR.from_contents(request.raw_post)
        render json: @exporter.issue(@fhir_params)
      end
      format.html do
        details
      end
    end
  end

  def details
    @jws_encoded_details = @exporter.jws
    @jws_header, @jws_fhir_payload, @jws_signature= @jws_encoded_details.to_s.split('.').map { |entry| HealthCards::JWS.decode(entry) }
    @health_card = HealthCards::HealthCard.from_jws @jws_encoded_details.to_s
    @qr_code_payload = @exporter.chunks
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
<<<<<<< HEAD
=======
    @payload_array = HealthCards::Importer.upload(file)
<<<<<<< HEAD

  def detail_patient
    
  end 
  private

  def health_card
    issuer.create_health_card(bundle)
  end

  def jws
    issuer.issue_jws(bundle)
>>>>>>> f778dc0 (a button leading to details page but the detail page linking is broken)
=======
>>>>>>> 58fb950 (not able to obtain the decoded_jws)
  end

  private

  def create_exporter
    @patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(@patient)
  end

end
