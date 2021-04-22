# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient

  def show
    respond_to do |format|
      format.healthcard { render json: health_card.to_json }
    end
  end

  def chunks
    render json: health_card.chunks.to_json
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

  # def download_pdf
  #   send_file(
  #     "#{Rails.root}/public/sample.pdf",
  #     filename: "sample.pdf",
  #     type: "application/pdf"
  #   )
  # end

  # def show
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       render :pdf => "report", :layout => 'pdf.html.haml'
  #     end
  #   end
  # end

  def index
    respond_to do |format|
      format.pdf do 
        @html = get_html
        @pdf = WickedPDF.new.pdf_from_string(@html)
        send_data(@pdf, :filename => 'Test', type: 'application/pdf')
      end
    end
  end

  def get_html
    ApplicationController::Base.new.render_to_string(template: 'v1/profile/reportes.pdf.erb',
                                                     orientation: 'Landscape',
                                                     page_size:'Letter',
                                                     background: 'true'
                                                     )
    end

end
