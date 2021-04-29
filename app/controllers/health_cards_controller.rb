# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: { verifiableCredential: [jws.to_s] } }
      format.pdf do #{ render json: { verifiableCredential: [jws.to_s] } }
        render pdf: "show", layout: 'pdf.html'
      end
    end
  end

    # render :pdf => “file.pdf”, :template => ‘basic_infos/show.html.erb’

  # def show
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       render pdf: "file_name"   # Excluding ".pdf" extension.
  #     end
  #   end
  # end

  # def pdf
  #   respond_to do |format|
  #     format.pdf { render json: { verifiableCredential: [jws.to_s] } }
  #   end
  # end




  def chunks
    render json: health_card.chunks.to_json
  end

  def scan; end

  def qr_contents
    contents = JSON.parse(params[:qr_contents])
    @jws_payload = HealthCards::Chunking.get_payload_from_qr contents
    @patient = helpers.create_patient_from_jws(@jws_payload)
  end

  private

  def health_card
    issuer.create_health_card(bundle)
  end

  def jws
    issuer.issue_jws(bundle)
  end

  def bundle
    @patient.to_bundle(issuer.url)
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def issuer
    Rails.application.config.issuer
  end
end
