# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'patient_manager'

set :port, 8000
set :static, true
set :public_folder, 'static'
set :views, 'frontend/src'

post '/Patient/' do
  request.body.rewind
  payload = JSON.parse(request.body.read)
  PatientManager.add_patient(payload)

  # attr_reader :given, :mi, :ln, :suffix, :gender, :telecom, :email, :birth_date

  # def initialize(given)
  #   @given = params['name'][0]['given'][0]
  # end


  # @given = params['name'][0]['given'][0]
  # @mi = params['name'][0]['given'][1]
  # @ln = params['name'][0]['family']
  # @suffix = params['name'][0]['suffix']
  # @gender = params['gender']
  # @telecom = params['telecom'][0]['phone']
  # @email = params['telecom'][0]['email']
  # @birth_date = params['birthDate']
    
  #return the post back to the client so it can know the id that was given
  #return the patient in add_patient
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

    PatientManager.get_patient_by_id(id)

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
