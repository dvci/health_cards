# frozen_string_literal: true

# require 'app/lib/covid_health_card_reporter'

# HealthCardsController is the endpoint for download and issue of health cards
class HealthCardsController < SecuredController
  before_action :create_exporter, except: [:scan, :qr_contents, :upload]
  skip_before_action :verify_authenticity_token, only: [:create]

  def show
    respond_to do |format|
      format.healthcard { render json: @exporter.download }
      format.html do
        @jws_encoded_details = @exporter.jws
        @health_card = HealthCards::COVIDHealthCard.from_jws @jws_encoded_details
        @qr_code_payload = @exporter.chunks

        if @qr_code_payload.length == 1
          @qr_code_payload[0] = "shc:/#{@qr_code_payload[0]}"
        else
          @qr_code_payload = qr_code_payload.map.with_index do |s, i|
            "shc:/#{i + 1}/#{@qr_code_payload.length}/#{s}"
          end
        end
      end
    end
  end

  def create
    respond_to do |format|
      format.fhir_json do
        fhir_params = FHIR.from_contents(request.raw_post)
        render json: @exporter.issue(fhir_params)
      end
      format.pdf do
        @image_uri = params[:qrcode]
        render pdf: 'health_card', layout: 'pdf', encoding: 'utf8'
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
    @patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(@patient)
  rescue ActiveRecord::RecordNotFound => e
    raise e unless params[:format] == 'fhir_json'

    issue = FHIR::OperationOutcome::Issue.new(severity: 'error', code: 'not-found',
                                              diagnostic: 'Patient does not exist')
    render json: FHIR::OperationOutcome.new(issue: issue).to_json, status: :not_found and return
  end
end
