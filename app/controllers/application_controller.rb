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
    if request.format == :fhir_json
      begin
        yield
      rescue StandardError => e
        case e
        when ActiveRecord::RecordNotFound
          render_operation_outcome('not-found', e, :not_found)
        when HealthCards::InvalidParametersError
          render_operation_outcome(e.code, e, :bad_request)
        else
          render_operation_outcome('exception', e, :internal_server_error)
        end
      end
    else
      yield
    end
  end

  def render_operation_outcome(code, error, status)
    issue = FHIR::OperationOutcome::Issue.new(severity: 'error', code: code, diagnostic: error.message)
    render json: FHIR::OperationOutcome.new(issue: issue).to_json, status: status
  end
end
