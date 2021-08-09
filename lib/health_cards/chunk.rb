# frozen_string_literal: true

# rubocop:disable Lint/MissingSuper
module HealthCards
  # Represents a single QRCode in a sequence. This class is a shim to the RQRCode library
  # to enable multimode encoding
  class Chunk < RQRCode::QRCode
    attr_reader :ordinal

    def data
      @qrcode.data
    end

    def initialize(ordinal: 1, input: nil)
      @ordinal = ordinal
      @qrcode = ChunkCore.new(input)
    end

    def image
      as_png(
        border_modules: 1,
        module_px_size: 2
      )
    end

    delegate :data, to: :qr_code

    def image
      @qrcode.as_png(module_px_size: 2)
    end
  end

  # RQRCodeCore shim for to enable multimode encoding
  class ChunkCore < RQRCodeCore::QRCode
    attr_accessor :data

    def initialize(input)
      @data = input
      @error_correct_level = 1
      @version = 22
      @module_count = @version * 4 + RQRCodeCore::QRPOSITIONPATTERNLENGTH
      @modules = Array.new(@module_count)
      @data_list = SHCQRCode.new(@data)
      @data_cache = nil
      make
    end

    # RQRCodeCore data shim for multimode encoding
    class SHCQRCode
      SINGLE_REGEX = %r{shc:/}.freeze
      MULTI_REGEX = %r{shc:/[0-9]*/[0-9]*/}.freeze

      def initialize(data)
        @data = data
      end

      def write(buffer)
        multi = MULTI_REGEX.match(@data)
        prefix = multi ? multi.to_s : SINGLE_REGEX.match(@data).to_s

        buffer.byte_encoding_start(prefix.length)

        prefix.each_byte do |b|
          buffer.put(b, 8)
        end

        num_content = @data.delete_prefix(prefix)

        buffer.numeric_encoding_start(num_content.length)

        num_content.size.times do |i|
          next unless (i % 3).zero?

          chars = num_content[i, 3]
          bit_length = get_bit_length(chars.length)
          buffer.put(get_code(chars), bit_length)
        end
      end

      private

      NUMBER_LENGTH = {
        3 => 10,
        2 => 7,
        1 => 4
      }.freeze

      def get_bit_length(length)
        NUMBER_LENGTH[length]
      end

      def get_code(chars)
        chars.to_i
      end
  end
end
# rubocop:enable Lint/MissingSuper
