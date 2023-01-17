# frozen_string_literal: true

module HealthCards
  VERSION = '1.1.1'

  def self.openssl_3?
    OpenSSL::OPENSSL_VERSION_NUMBER >= 3 * 0x10000000
  end
end
