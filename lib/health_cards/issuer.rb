# frozen_string_literal: true

require_relative 'keys'

# Verifiable Credential Issuer
#
# https://www.w3.org/TR/vc-data-model/#issuer
module HealthCards
  class Issuer
    include Keys

    attr_reader :key_path

    def initialize(key_path = Pathname.new('.'))
      @key_path = key_path
    end

    def signing_key_path
      key_path.join 'signing_key.pem'
    end

    def encryption_key_path
      key_path.join 'encryption_key.pem'
    end

    def signing_key
      @signing_key ||= check_key_exists(signing_key_path, 'sig')
    end

    def encryption_key
      @encryption_key ||= check_key_exists(encryption_key_path, 'enc')
    end

    def jwks
      @jwks ||= {
        keys: [signing_key[:jwk], encryption_key[:jwk]]
      }
    end

    # Load keys from disc if they exist else generate new keys and save
    def check_key_exists(path, type)
      return load_key(path, type) if File.exist?(path)

      # Create key directory if it doesn't exist
      Dir.mkdir(key_path) unless Dir.exist?(key_path)

      if type == 'sig'
        generate_signing_key(path)
      else
        generate_encryption_key(path)
      end
    end
  end
end
