# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: { verifiableCredential: [jws.to_s] } }
      format.pdf do #{ render json: { verifiableCredential: [jws.to_s] } }
        # Request body 

        render pdf: "health_card", layout: 'pdf.html', encoding: 'utf8'# , window_status: 'ready_to_print'
      end
      format.html
    end
  end

  def qrcode
    
  end

  def chunks
    render json: jws.chunks
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
