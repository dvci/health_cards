# frozen_string_literal: true

module HealthCards
  # A key used for signing JWS
  class PrivateKey < Key
    def self.from_file(path)
      pem = OpenSSL::PKey::EC.new(File.read(path))
      PrivateKey.new(pem)
    end

    def self.load_from_or_create_from_file(path)
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
      asn1_to_raw(@key.sign(OpenSSL::Digest.new('SHA256'), payload), self)
    end

    def public_key
      return @public_key if @public_key

      @public_key = if HealthCards.openssl_3?
                      public_key_openssl3
                    else
                      public_key_openssl1
                    end
    end

    private

    def public_key_openssl3
      # Largely taken, then slightly modified from
      # https://github.com/jwt/ruby-jwt/blob/main/lib/jwt/jwk/ec.rb#L131 on 2022-01-17
      curve = 'prime256v1'
      point = @key.public_key
      sequence = OpenSSL::ASN1::Sequence([
                                           OpenSSL::ASN1::Sequence([OpenSSL::ASN1::ObjectId('id-ecPublicKey'), OpenSSL::ASN1::ObjectId(curve)]),
                                           OpenSSL::ASN1::BitString(point.to_octet_string(:uncompressed))
                                         ])
      pub = OpenSSL::PKey::EC.new(sequence.to_der)
      PublicKey.new(pub)
    end

    def public_key_openssl1
      pub = OpenSSL::PKey::EC.new('prime256v1')
      pub.public_key = @key.public_key
      PublicKey.new(pub)
    end

    # Convert the ASN.1 Representation into the raw signature
    #
    # Adapted from ruby-jwt and json-jwt gems. More info here:
    # https://github.com/nov/json-jwt/issues/21
    # https://github.com/jwt/ruby-jwt/pull/87
    # https://github.com/jwt/ruby-jwt/issues/84
    def asn1_to_raw(signature, private_key)
      byte_size = (private_key.group.degree + 7) / 8
      OpenSSL::ASN1.decode(signature).value.map { |value| value.value.to_s(2).rjust(byte_size, "\x00") }.join
    end
  end
end
