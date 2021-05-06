# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < ApplicationController
  before_action :create_exporter, except: [:scan, :qr_contents, :upload]
  skip_before_action :verify_authenticity_token, only: [:create]
  after_action :set_cors_header, only: :create

  def show
    respond_to do |format|
      format.healthcard { render json: { verifiableCredential: [jws.to_s] } }
      format.html do
        details
    end
  end
end 

  def chunks
    render json: @exporter.chunks
  end

  def scan; end

  def details
    @jws_encoded_details = jws
    # @jws_decoded_details = HealthCards::JWS.to_s @jws_encoded_details
    # @jws_header, @jws_payload, @jws_signature = jws_contents.split('.').map { |entry| decode(jws_encoded_details) }
    @bundle_details = bundle.to_json
  end 

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

  def detail_patient
    
  end 
  private

  def health_card
    issuer.create_health_card(bundle)
  end

  def jws
    issuer.issue_jws(bundle)
>>>>>>> f778dc0 (a button leading to details page but the detail page linking is broken)
  end

  private

  def create_exporter
    patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(patient)
  end

  def issuer
    Rails.application.config.issuer
  end
end
