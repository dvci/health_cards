require 'sinatra'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
    erb :patient_form
end

post '/patient/' do
    fn = params[:fn]
    mi = params[:mi] || "Nothing"
    ln = params[:ln]
    suffix = params[:suffix]
    gender = params[:gender]
    mobile = params[:mobile]
    email = params[:email]
    dob = params[:dob]

    erb :index, :locals => {'fn' => fn, 'mi' => mi, 'ln' => ln,
        'suffix' => suffix, 'gender' => gender, 'mobile' => mobile,
        'email' => email, 'date' => dob}
end
    
