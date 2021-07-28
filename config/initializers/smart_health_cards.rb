# frozen_string_literal: true

require 'health_cards'

Rails.application.configure do
  config.smart = config_for('well-known')
  config.metadata = config_for('metadata')
  config.operation = config_for('operation')

  config.hc_key_path = ENV['KEY_PATH']
  FileUtils.mkdir_p(File.dirname(ENV['KEY_PATH']))
  kp = HealthCards::PrivateKey.load_from_or_create_from_file(config.hc_key_path)

  config.hc_key = kp
  config.issuer = HealthCards::Issuer.new(url: ENV['HOST'], key: config.hc_key)

  config.auth_code = ENV['AUTH_CODE']
  config.client_id = ENV['CLIENT_ID']

  config.username = ENV['IIS_SANDBOX_USERNAME']
  config.password = ENV['IIS_SANDBOX_PASSWORD']
  config.facilityID = ENV['IIS_SANDBOX_FACILITYID']
  
  config.iisSandboxHost = ENV['IIS_SANDBOX_HOST']
  config.v2ToFhirHost = ENV['V2_TO_FHIR_HOST']
end
