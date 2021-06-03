# frozen_string_literal: true

module HealthCards
  # Implements QR Code chunking in ruby
  class QRCodes
    attr_reader :chunks

    def self.from_jws(jws)
      QRCodes.new(ChunkingUtils.jws_to_qr_chunks(jws.to_s))
    end

    def initialize(chunks)
      @chunks = chunks.sort.map.with_index(1) { |ch, i| Chunk.new(ordinal: i, input: ch) }
    end

    def single?
      chunks.count == 1
    end

    def code_by_ordinal(num)
      chunks.find { |ch| ch.ordinal == num }
    end

    def to_jws
      ChunkingUtils.qr_chunks_to_jws(chunks.map(&:data))
    end
  end

  # rubocop:disable Lint/MissingSuper

  # RQR Shim for Encoding
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
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 650
      )
    end
  end

  # RQRCode shim for encoding
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

    # RQRCode shim for encoding
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
    # rubocop:enable Lint/MissingSuper
  end
end
