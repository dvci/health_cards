# frozen_string_literal: true

json.extract! immunization, :id, :patient, :vaccine, :occurrence, :lot_number, :created_at, :updated_at
json.url immunization_url(immunization, format: :json)
