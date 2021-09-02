# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < SecuredController
  before_action :find_patient, only: [:show, :create]

  skip_before_action :verify_authenticity_token, only: [:create]

  def show
    respond_to do |format|
      format.healthcard { render json: exporter.download }
      format.html do
        @jws_encoded_details = exporter.jws
        @health_card = HealthCards::COVIDImmunizationCard.from_jws @jws_encoded_details
        @qr_codes = exporter.qr_codes
      end
      format.pdf do
        @qr_codes = exporter.qr_codes
        render pdf: 'health_card', layout: 'pdf', encoding: 'utf8'
      end
    end
  end

  def create
    respond_to do |format|
      format.fhir_json do
        fhir_params = FHIR.from_contents(request.raw_post)
        render json: exporter.issue(fhir_params)
      end
    end
  end

  def upload
    @filename = params[:health_card].original_filename
    file = params.require(:health_card).read
    @upload_result = HealthCards::Importer.upload(file)
  end
end
