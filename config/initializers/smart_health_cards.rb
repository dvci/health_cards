# frozen_string_literal: true

require 'health_cards'

Rails.application.configure do
  config.well_known = config_for('well-known')
  key_store = HealthCards::FileKeyStore.new(config.well_known.jwk[:key_path])
  config.issuer = HealthCards::Issuer.new(key_store)
end
