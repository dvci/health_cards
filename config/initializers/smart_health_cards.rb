# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib/health_cards/lib'
require 'health_cards'

Rails.application.configure do
  config.smart = config_for('well-known')

  config.hc_key_path = ENV['KEY_PATH']
  FileUtils.mkdir_p(File.dirname(ENV['KEY_PATH']))
  kp = HealthCards::PrivateKey.load_from_or_create_from_file(config.hc_key_path)

  config.hc_key = kp
  config.issuer = HealthCards::Issuer.new(url: ENV['HOST'], key: config.hc_key)
end
