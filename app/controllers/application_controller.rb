# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def set_cors_header
    response.header['Access-Control-Allow-Origin'] = '*'
  end

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
