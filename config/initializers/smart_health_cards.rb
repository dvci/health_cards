# frozen_string_literal: true

require 'health_cards'

Rails.application.configure do
  config.smart = config_for('well-known')

  config.hc_key_path = ENV['KEY_PATH']
  FileUtils.mkdir_p(File.dirname(ENV['KEY_PATH']))
  kp = HealthCards::KeyPair.new(config.hc_key_path)

  config.hc_key_pair = kp
  config.hc_public_key = kp.public_key
  config.hc_private_key = kp.private_key
end
