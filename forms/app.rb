# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'fhir_client'
require 'fhir_models'
require 'uri'

set :port, 8080
set :static, true
set :public_folder, 'static'
set :views, 'views'

# client = FHIR::Client.new(localhost:8080)
# FHIR::Model.client = client
# client.default_json

# before do
#   content_type :application/fhir+json
# end


get '/' do
  erb :patient_form
end

post '/Patient/', :provides => :json do
  #data will be in the body and not params when I change it into application/json
  # request.body.rewind
  # data_payload = JSON.parse request.body.read
  # puts data_payload

  # patient = { given: data_payload['given'], 
  #             mi: data_payload['mi'], 
  #             ln: data_payload['ln'], 
  #             suffix: data_payload['suffix'],
  #             gender: data_payload['gender'],
  #             telecom: data_payload['telecom'],
  #             email: data_payload['email']
  #             birthdate: data_payload['birthdate'] }

  # given = data_payload['given']
  # mi = data_payload['mi']
  # ln = data_payload['ln']
  # suffix = data_payload['suffix']
  # gender = data_payload['gender']
  # telecom = data_payload['telecom']
  # email = data_payload['email']
  # birthdate = data_payload['birthdate']

  given = params['given']
  mi = params['mi']
  ln = params['ln']
  suffix = params['suffix']
  gender = params['gender']
  telecom = params['telecom']
  email = params['email']
  birthdate = params['birthdate']

  erb :index, locals: { 'given' => given, 'mi' => mi, 'ln' => ln,
                        'suffix' => suffix, 'gender' => gender, 'telecom' => telecom,
                        'email' => email, 'birthdate' => birthdate }
end

get '/Patient' do
  #content_type :application/fhir+json
  # gender = { "gender" => params['gender'] }
  # gender.to_json
  patient = { 'given' => params['given'], 'mi' => params['mi'], 'ln' => params['ln'], 'suffix' => params['suffix'],
              'gender' => params['gender'], 'telecom' => params['telecom'],
              'email' => params['email'], 'birthdate' => params['birthdate'] }
  patient.to_json
end


# reply = client.read_feed(FHIR::Patient) # fetch Bundle of Patients
# bundle = reply.resource
# bundle.entry.each do |entry|
#   patient = entry.resource
#   puts patient.name[0].text
# end
# puts reply.code # HTTP 200 (or whatever was returned)
# puts reply.body # Raw XML or JSON


#fix frontend to send the data correctly - submit as a request body and valid fhir resource 
#take it from the backend and make sure it is a fhir resource