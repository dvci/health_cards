# frozen_string_literal: true

module HealthCards
  # Represents a single QRCode in a sequence. This class is a shim to the RQRCode library
  # to enable multimode encoding
  class Chunk
    attr_reader :ordinal, :data, :qrcode

    SINGLE_REGEX = %r{shc:/}.freeze
    MULTI_REGEX = %r{shc:/[0-9]*/[0-9]*/}.freeze

    def initialize(input:, ordinal: 1)
      @ordinal = ordinal
      @data = input
      multi = MULTI_REGEX.match(input)

      prefix = multi ? multi.to_s : SINGLE_REGEX.match(input).to_s
      content = input.delete_prefix(prefix)

      @qrcode = RQRCode::QRCode.new([{ mode: :byte_8bit, data: prefix }, { mode: :number, data: content }],
                                    max_size: 22, level: :l)
    end

    def qr_code
      @qrcode.qrcode
    end

    def image
      @qrcode.as_png(module_px_size: 2)
    end
  end
end
