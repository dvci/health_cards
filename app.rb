# frozen_string_literal: true

require 'sinatra'
require 'json'

set :port, 8000
set :static, true
set :public_folder, 'static'
set :views, 'frontend/src'

post '/Patient/' do
    request.body.rewind
    @data_payload = JSON.parse request.body.read
  
    @given = data_payload['given']
    @mi = data_payload['mi']
    @ln = data_payload['ln']
    @suffix = data_payload['suffix']
    @gender = data_payload['gender']
    @telecom = data_payload['telecom']
    @email = data_payload['email']
    @birthdate = data_payload['birthdate']
  
    @name = params["name"]
    puts @name
  
  end

get '/Patient/' do
    "Hello World"
    @given = params["name"]
    
  end


# get '/Patient' do
#   #content_type :application/fhir+json
#   patient = { 'given' => data_payload['given'], 'mi' => data_payload['mi'], 'ln' => data_payload['ln'], 'suffix' => data_payload['suffix'],
#               'gender' => data_payload['gender'], 'telecom' => data_payload['telecom'],
#               'email' => data_payload['email'], 'birthdate' => data_payload['birthdate'] }
# end