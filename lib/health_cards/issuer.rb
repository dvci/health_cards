# frozen_string_literal: true

require_relative 'keys'

# Verifiable Credential Issuer
#
# https://www.w3.org/TR/vc-data-model/#issuer
class Issuer
  include Keys

  KEYS_DIR_PATH = 'lib/health_cards/keys'
  SIGNING_KEY_PATH = 'lib/health_cards/keys/signing_key.pem'
  ENCRYPTION_KEY_PATH = 'lib/health_cards/keys/encryption_key.pem'
  UPDATE_KEY_PATH = 'lib/health_cards/keys/update_key.pem'
  RECOVERY_KEY_PATH = 'lib/health_cards/keys/recovery_key.pem'

  def initialize
    # Create key directory if it doesn't exist
    Dir.mkdir(KEYS_DIR_PATH) unless Dir.exist?(KEYS_DIR_PATH)

    # If keys exist, load from pem file else generate new key and save
    @signing_jwk = check_key_exists SIGNING_KEY_PATH
    @encryption_jwk = check_key_exists ENCRYPTION_KEY_PATH
    @update_jwk = check_key_exists UPDATE_KEY_PATH
    @recovery_jwk = check_key_exists RECOVERY_KEY_PATH
    Rails.logger.info @signing_jwk
    Rails.logger.info @encryption_jwk
  end

  def check_key_exists(path)
    File.exist?(path) ? load_key(path) : generate_key(path)
  end
end
