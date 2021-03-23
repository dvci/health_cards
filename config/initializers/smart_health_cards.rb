require 'health_cards'

Rails.application.configure do
  config.well_known = config_for('well-known')
  config.issuer = HealthCards::Issuer.new(config.well_known.jwk[:key_path])
end