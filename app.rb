# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'json'
require_relative 'patient_manager'

set :port, 8000
set :static, true
set :public_folder, 'static'
set :views, 'frontend/src'

post '/Patient' do
  request.body.rewind
  payload = JSON.parse(request.body.read)
  x = PatientManager.add_patient(payload)
  json x
  puts x
end

get '/Patient/{id}' do
  # {
  #   resourceType: 'Patient',
  #   name: [
  #     {
  #       given: [@given, @mi],
  #       family: @ln,
  #       suffix: @suffix
  #     }
  #   ],
  #   gender: @gender,
  #   telecom: [
  #     {
  #       phone: @telecom,
  #       email: @email
  #     }
  #   ],
  #   birthDate: @birth_date
  # }.to_json

    x = PatientManager.get_patient_by_id(id)
    puts x

  #   {
  #   resourceType: 'Patient',
  #   name: [
  #     {
  #       given: [PatientManager.patientbyId, PatientManager.mi],
  #       family: PatientManager.ln,
  #       suffix: PatientManager.suffix
  #     }
  #   ],
  #   gender: PatientManager.gender,
  #   telecom: [
  #     {
  #       phone: PatientManager.telecom,
  #       email: PatientManager.email
  #     }
  #   ],
  #   birthDate: PatientManager.birthDate
  # }.to_json
end
