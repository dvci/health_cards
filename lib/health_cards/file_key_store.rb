# frozen_string_literal: true

require 'openssl'

module HealthCards
  # Methods to generate signing keys and jwk
  class FileKeyStore
    FILE_NAME = 'signing_key.pem'

    def initialize(path)
      @path = Pathname.new(path)
      Dir.mkdir(@path) unless Dir.exist?(@path)
    end

    def load_or_create_key
      create_key unless File.exist?(key_path)
      load_key(key_path)
    end

    def key_path
      @path.join(FILE_NAME)
    end

    def create_key
      key = OpenSSL::PKey::EC.generate('prime256v1')
      File.write(key_path, key.to_pem)
      key
    end

    # Load key from pem file
    def load_key(_path)
      OpenSSL::PKey::EC.new(File.read(key_path))
    end
  end
end
