# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'landing_page#index'

  resources :patients do
    resources :immunizations
    resource :health_card do
      get 'chunks', format: :json

    end
    #check syntax into getting details to show up
  end

  resources :health_cards do
    collection do
      get 'scan'
      post 'upload'
      post 'qr_contents'
    end
  end

  post '/Patient/:patient_id/$health-cards-issue', to: 'health_cards#create', as: :issue_vc, format: :fhir_json
  get "/Patient/:id", to: "patients#show", as: :fhir_patient, format: :fhir_json
  get "/Immunization/:id", to: "immunizations#show", as: :fhir_immunization, format: :fhir_json
  get "/.well-known/smart-configuration", to: "well_known#smart", as: :well_known_smart, format: :json
  get "/.well-known/jwks", to: "well_known#jwks", as: :well_known_jwks, format: :json

<<<<<<< HEAD
=======
  get '/health_cards/scan', to: 'health_cards#scan', as: :scan_health_card
  post '/health_cards/qr_contents', to: 'health_cards#qr_contents', as: :health_card_qr_contents
>>>>>>> b8ff491 (a button leading to details page but the detail page linking is broken)
end
