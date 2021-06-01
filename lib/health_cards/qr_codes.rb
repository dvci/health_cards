# frozen_string_literal: true

module HealthCards
  # Implements QR Code chunking in ruby
  class QRCodes
    attr_reader :chunks

    def initialize(jws: nil)
      # if 1 chunk, attach prefix shc:/
      # if multiple chunks, attach prefix shc:/$orderNumber/$totalChunkCount
      chunks = Chunking.generate_qr_chunks(jws)
      if chunks.length == 1
        chunks[0] = "shc:/#{chunks[0]}"
      else
        chunks.each_with_index do |ch, i|
          chunks[i] = "shc:/#{i + 1}/#{chunks.length}/#{ch}"
        end
      end
      @chunks = chunks.map { |ch| Chunk.new(ch) }
    end
  end

  # rubocop:disable Lint/MissingSuper

  # RQR Shim for Encoding
  class Chunk < RQRCode::QRCode
    def initialize(string, *_args)
      @qrcode = ChunkCore.new(string)
    end
  end

  # RQRCode shim for encoding
  class ChunkCore < RQRCodeCore::QRCode
    MAX_CHUNK_SIZE = 1191

    def initialize(input)
      @data = input
      @error_correct_level = 1
      @version = 22
      @module_count = @version * 4 + RQRCodeCore::QRPOSITIONPATTERNLENGTH
      @modules = Array.new(@module_count)
      # super(input, size: 22, level: :l, mode: :number)
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

          chars = @data[i, 3]
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
