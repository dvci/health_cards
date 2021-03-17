# frozen_string_literal: true

Rails.application.routes.draw do

  root 'patients#new'
  resources :patients do
    resources :immunizations
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "/.well-known/smart-configuration", to: "well_known#index", as: :well_known, format: :json
  get "/.well-known/jwks", to: "well_known#jwks", as: :well_known_jwks, format: :json
end
