# frozen_string_literal: true

# HealthCardsController is the endpoint for download of health cards
# In the future issue endpoint will use this controller as well
class HealthCardsController < ApplicationController
  before_action :find_patient, except: [:scan, :qr_contents]

  def show
    respond_to do |format|
      vc = jws.to_s
      format.healthcard { render json: { verifiableCredential: [vc] } }
      format.fhir_json do
        fhir_params = FHIR.from_contents(request.raw_post)
        types = nil
        err_msg = nil

        if fhir_params.nil?
          err_msg = 'Unable to find FHIR::Parameter JSON'
        elsif !fhir_params.valid?
          err_msg = fhir_params.validate.to_s
        else
          types = fhir_params.parameter.map(&:valueUri).compact
          err_msg = 'Invalid Parameter: Expected valueUri' if types.empty?
        end

        if err_msg
          render json: FHIR::OperationOutcome.new(severity: 'error', code: 'invalid',
                                                  diagnostics: err_msg).to_json and return
        end

        out_params = FHIR::Parameters.new(parameter: [])
        if HealthCards::COVIDHealthCard.supports_type?(*types)
          out_params.parameter << FHIR::Parameters::Parameter.new(name: 'verifiableCredential', valueString: vc)
        end

        render json: out_params.to_json
      end
    end
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
