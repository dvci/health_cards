# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'landing_page#index'

  resources :patients do
    resources :immunizations
    resources :lab_results
    resource :health_card, except: :upload do
      member do
        resources :qr_codes, only: :show
      end
    end
  end

  resources :qr_codes, only: [:new, :create]

  resources :health_cards, only: :upload do
    collection do
      post :upload
    end
  end

  post '/Patient/:patient_id/$health-cards-issue', to: 'health_cards#create', as: :issue_vc, format: :fhir_json
  get '/Patient/:id', to: 'patients#show', as: :fhir_patient, format: :fhir_json
  get '/Immunization/:id', to: 'immunizations#show', as: :fhir_immunization, format: :fhir_json
  get "/LabResult/:id", to: "lab_results#show", as: :fhir_lab_result, format: :fhir_json
  get '/.well-known/smart-configuration', to: 'well_known#smart', as: :well_known_smart, format: :json
  get '/.well-known/jwks', to: 'well_known#jwks', as: :well_known_jwks, format: :json
  get '/metadata', to: 'metadata#capability_statement', as: :fhir_capabilitystatement, format: :fhir_json
  get '/OperationDefinition/health-cards-issue', to: 'metadata#operation_definition', as: :fhir_operationdefinition, format: :fhir_json
  get '/fhir_instructions', to: 'landing_page#fhir_instructions', as: :fhir_instructions

  get '/auth/authorize', to: 'auth#authorize', as: :auth_code
  post '/auth/token', to: 'auth#token', as: :auth_token
end
