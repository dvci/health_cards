# frozen_string_literal: true

require 'sinatra'
require 'json'

set :port, 8000
set :static, true
set :public_folder, 'static'
set :views, 'frontend/src'

post '/Patient/' do
  request.body.rewind
  params = JSON.parse(request.body.read)

  @given = params['name'][0]['given'][0]
  @mi = params['name'][0]['given'][1]
  @ln = params['name'][0]['family']
  @suffix = params['name'][0]['suffix']
  @gender = params['gender']
  @telecom = params['telecom'][0]['phone']
  @email = params['telecom'][0]['email']
  @birth_date = params['birthDate']
end

get '/Patient/' do
  {
    resourceType: 'Patient',
    name: [
      {
        given: [@given, @mi],
        family: @ln,
        suffix: @suffix
      }
    ],
    gender: @gender,
    telecom: [
      {
        phone: @telecom,
        email: @email
      }
    ],
    birthDate: @birth_Date
  }.to_json
end
