# frozen_string_literal: true

json.extract! patient, :id, :json, :created_at, :updated_at
json.url patient_url(patient, format: :json)
