# frozen_string_literal: true

require 'sinatra'
require 'json'

set :port, 8080
set :static, true
set :public_folder, 'static'
set :views, 'views'

get '/' do
  erb :patient_form
end

post '/Patient/' do
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
  content_type :json
  # gender = { "gender" => params['gender'] }
  # gender.to_json
  patient = { 'given' => params['given'], 'mi' => params['mi'], 'ln' => params['ln'], 'suffix' => params['suffix'],
              'gender' => params['gender'], 'telecom' => params['telecom'],
              'email' => params['email'], 'birthdate' => params['birthdate'] }
  patient.to_json
end
