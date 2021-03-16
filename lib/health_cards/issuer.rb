# frozen_string_literal: true

require_relative 'keys'

module HealthCards
  # Verifiable Credential Issuer
  #
  # https://www.w3.org/TR/vc-data-model/#issuer
  class Issuer
    include Keys

    attr_reader :key_path

    def initialize(key_path = Pathname.new('.'))
      @key_path = key_path
    end

    def signing_key_path
      key_path.join 'signing_key.pem'
    end

    def signing_key
      @signing_key ||= check_key_exists(signing_key_path)
    end

    def jwks
      @jwks ||= {
        keys: [signing_key[:jwk]]
      }
    end

    # Load keys from disc if they exist else generate new keys and save
    def check_key_exists(path)
      return load_key(path) if File.exist?(path)

      # Create key directory if it doesn't exist
      Dir.mkdir(key_path) unless Dir.exist?(key_path)
      generate_signing_key(path)
    end
  end
end
