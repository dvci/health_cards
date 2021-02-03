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
  fn = params['fn']
  mi = params['mi']
  ln = params['ln']
  suffix = params['suffix']
  gender = params['gender']
  mobile = params['mobile']
  email = params['email']
  dob = params['dob']

  erb :index, locals: { 'fn' => fn, 'mi' => mi, 'ln' => ln,
                        'suffix' => suffix, 'gender' => gender, 'mobile' => mobile,
                        'email' => email, 'date' => dob }
end

get '/Patient' do 
  content_type :json
  #gender = { "gender" => params['gender'] }
  #gender.to_json
  patient = { "fn" => params['fn'], "mi" => params['mi'], "ln" => params['ln'], "suffix" => params['suffix'], "gender" => params['gender'],
              "mobile" => params['mobile'], "email" => params['email'], "dob" => params['dob'] }
  patient.to_json
end