# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < SecuredController
  before_action :find_patient, only: [:show, :create]
  before_action :health_card, only: :show
  skip_before_action :verify_authenticity_token, only: [:create]

  def show
    respond_to do |format|
      format.healthcard { render json: health_card.to_json }
      format.html
      format.pdf do
        render pdf: 'health_card', layout: 'pdf', encoding: 'utf8'
      end
    end
  end

  def create
    respond_to do |format|
      format.fhir_json do
        fhir_params = FHIR.from_contents(request.raw_post)
        out_params = HealthCards::Exporter.issue(fhir_params) do |types|
          HealthCards::COVIDImmunizationPayload.supports_type?(types) ? health_card.jws : nil
        end
        render json: out_params
      end
    end
  end

  def upload
    @filename = params[:health_card].original_filename
    file = params.require(:health_card).read
    @upload_result = HealthCards::Importer.upload(file)
  end
end
