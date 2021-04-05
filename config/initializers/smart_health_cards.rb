# frozen_string_literal: true

require 'health_cards'

Rails.application.configure do
  config.smart = config_for('well-known')

  config.hc_key_path = ENV['KEY_PATH']
  FileUtils.mkdir_p(File.dirname(ENV['KEY_PATH']))
  kp = HealthCards::PrivateKey.from_file!(config.hc_key_path)

  config.hc_key = kp
end
