# frozen_string_literal: true

require 'health_cards'

Rails.application.configure do
  config.smart = config_for('well-known')
  config.hc_key_path = ENV['KEY_PATH']
  config.hc_key = HealthCards::Key.load_file(config.hc_key_path)
end
