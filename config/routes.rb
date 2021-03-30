# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'landing_page#index'

  resources :immunizations, only: :show

  resources :patients do
    resources :immunizations
    resource :health_card, only: :show
  end

  get "/.well-known/smart-configuration", to: "well_known#smart", as: :well_known_smart, format: :json
  get "/.well-known/jwks", to: "well_known#jwks", as: :well_known_jwks, format: :json
end
