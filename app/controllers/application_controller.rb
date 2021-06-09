# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def create_exporter
    @patient = Patient.find(params[:patient_id])
    @exporter = COVIDHealthCardExporter.new(@patient)
  rescue ActiveRecord::RecordNotFound => e
    respond_to do |format|
      format.fhir_json do
        issue = FHIR::OperationOutcome::Issue.new(severity: 'error', code: 'not-found',
                                                  diagnostic: 'Patient does not exist')
        render json: FHIR::OperationOutcome.new(issue: issue).to_json, status: :not_found and return
      end
    end
    raise e
  end
end
