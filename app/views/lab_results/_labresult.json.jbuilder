# frozen_string_literal: true

json.extract! lab_result, :id, :patient, :effective, :status, :code, :created_at, :updated_at
json.url lab_result_url(lab_result, format: :json)
