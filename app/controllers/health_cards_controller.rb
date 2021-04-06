# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      format.healthcard { render json: health_card.to_json }
    end
  end

  def chunks
    render json: health_card.chunks.to_json
  end

  def scan; end

  def qr_contents
    contents = JSON.parse(params[:qr_contents])
    jws_payload = HealthCards::Chunking.get_payload_from_qr contents
    bundle = FHIR.from_contents(jws_payload['vc']['credentialSubject']['fhirBundle'].to_json)

    patient_resource = bundle.entry.select { |e| e.resource.is_a?(FHIR::Patient) }[0].resource
    @pat = Patient.new(json: patient_resource)
    create_immunizations bundle

    respond_to do |format|
      format.html
    end
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

  def create_immunizations(bundle)
    immunizations = bundle.entry.select { |e| e.resource.is_a?(FHIR::Immunization) }
    vaccine_id_map = {
      '207': 1,
      '208': 2,
      '212': 3
    }

    immunizations.each do |i|
      immunization_resource = i.resource
      @pat.immunizations.new({
                               vaccine_id: vaccine_id_map[immunization_resource.vaccineCode.coding[0].code.to_sym],
                               lot_number: immunization_resource.lotNumber,
                               occurrence: immunization_resource.occurrenceDateTime
                             })
    end
  end
end
