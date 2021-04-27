# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: { verifiableCredential: [jws.to_s] } }
    end
  end

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

  def jws
    issuer.issue_jws(bundle)
  end

  def health_card
    issuer.create_health_card(bundle)
  end

  def bundle
    bundle = FHIR::Bundle.new
    bundle.entry << FHIR::Bundle::Entry.new(fullUrl: fhir_patient_url(@patient), resource: @patient.json)
    @patient.immunizations.each_with_object(bundle) do |imm, bun|
      json = imm.json
      json.patient.reference = fhir_immunization_url(imm)
      entry = FHIR::Bundle::Entry.new(fullUrl: fhir_immunization_url(imm), resource: json)
      bun.entry << entry
    end
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def issuer
    Rails.application.config.issuer
  end
end
