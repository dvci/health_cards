# frozen_string_literal: true

module HealthCards
  # A key used for signing JWS
  class PrivateKey < Key
    def self.from_file(path)
      pem = OpenSSL::PKey::EC.new(File.read(path))
      PrivateKey.new(pem)
    end

    def self.load_for_create_from_file(path)
      if File.exist?(path)
        from_file(path)
      else
        generate_key(file_path: path)
      end
    end

    def self.generate_key(file_path: nil)
      key = OpenSSL::PKey::EC.generate('prime256v1')
      File.write(file_path, key.to_pem) if file_path
      PrivateKey.new(key)
    end

    def sign(payload)
      @key.dsa_sign_asn1(payload)
    end

    def public_key
      return @public_key if @public_key

      pub = OpenSSL::PKey::EC.new('prime256v1')
      pub.public_key = @key.public_key
      @public_key = PublicKey.new(pub)
    end
  end
end
