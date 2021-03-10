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

  def initialize
    # Create key directory if it doesn't exist
    Dir.mkdir(KEYS_DIR_PATH) unless Dir.exist?(KEYS_DIR_PATH)

    @signing_key = check_key_exists(SIGNING_KEY_PATH, 'sig')
    @encryption_key = check_key_exists(ENCRYPTION_KEY_PATH, 'enc')
    @jwks = {
      keys: [@signing_key[:jwk], @encryption_key[:jwk]]
    }

    Rails.logger.info JSON.pretty_generate(@jwks)
  end

  # Load keys from disc if they exist else generate new keys and save
  def check_key_exists(path, type)
    if File.exist?(path)
      load_key(path, type)
    elsif type == 'sig'
      generate_signing_key(path)
    else
      generate_encryption_key(path)
    end
  end
end
