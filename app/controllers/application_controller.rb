# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :handle_fhir_errors

  private

  def exporter
    @exporter ||= PatientExporter.new(@patient)
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def handle_fhir_errors
    if request.format.json? || request.format.fhir_json?
      begin
        yield
      rescue StandardError => e
        case e
        when ActiveRecord::RecordNotFound
          render_operation_outcome(code: 'not-found', http: :not_found, error: e)
        when HealthCards::InvalidParametersError
          render_operation_outcome(code: e.code, http: :bad_request, error: e)
        else
          render_operation_outcome(code: 'exception', http: :internal_server_error, error: e)
        end
      end
    else
      yield
    end
  end

  def render_operation_outcome(code: nil, http: nil, error: nil, message: nil)
    diag = error ? error.message : message
    issue = FHIR::OperationOutcome::Issue.new(severity: 'error', code: code, diagnostic: diag)
    render json: FHIR::OperationOutcome.new(issue: issue).to_json, status: http
  end
end
