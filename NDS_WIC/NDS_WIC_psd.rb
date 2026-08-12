# encoding: utf-8
# ==============================================================================
# 파일명: NDS_WIC_psd.rb
# 인코딩: UTF-8
# 설명: [NDS-WIC] 고속 BGRA 채널 분리 및 PSD 패커 (색상 변색 방지 수정판)
# ==============================================================================

module NDS_Extensions
  module NDS_WIC
    module PsdWriter
      module_function

      # [정밀 수정: 스케치업 ImageRep의 BGRA 데이터를 포토샵 RGBA 채널로 정확히 정렬]
      def extract_channels_fast(raw_bgra, width, height)
        pixel_count = width * height
        all_bytes = raw_bgra.unpack('C*')
        len = all_bytes.size

        r_arr = Array.new(pixel_count)
        g_arr = Array.new(pixel_count)
        b_arr = Array.new(pixel_count)
        a_arr = Array.new(pixel_count)

        j = 0
        i = 0
        while i < len
          # SketchUp ImageRep.data 바이트 순서: [0]=Blue, [1]=Green, [2]=Red, [3]=Alpha
          b_arr[j] = all_bytes[i]     || 0
          g_arr[j] = all_bytes[i + 1] || 0
          r_arr[j] = all_bytes[i + 2] || 0
          a_arr[j] = all_bytes[i + 3] || 255
          i += 4
          j += 1
        end

        {
          :r => r_arr.pack('C*'),
          :g => g_arr.pack('C*'),
          :b => b_arr.pack('C*'),
          :a => a_arr.pack('C*')
        }
      end

      # BMP 파일 파싱 시 BGRA 순서로 정렬하여 반환
      def read_bmp_bgra(bmp_path)
        return nil unless File.exist?(bmp_path)

        data = File.binread(bmp_path)
        return nil if data.nil? || data.bytesize < 54 || data[0, 2] != 'BM'

        off_bits = data[10, 4].unpack('V')[0]
        width    = data[18, 4].unpack('V')[0]
        height   = data[22, 4].unpack('V')[0].abs
        bpp      = data[28, 2].unpack('v')[0]

        return nil unless bpp == 24 || bpp == 32

        row_bytes = ((bpp * width + 31) / 32) * 4
        pixel_data = data[off_bits..-1]
        return nil if pixel_data.nil?

        bgra = String.new(capacity: width * height * 4)

        (height - 1).downto(0) do |y|
          row_start = y * row_bytes
          row = pixel_data[row_start, row_bytes]
          next if row.nil?

          bytes = row.unpack('C*')
          0.upto(width - 1) do |x|
            if bpp == 24
              idx = x * 3
              b = bytes[idx] || 0
              g = bytes[idx + 1] || 0
              r = bytes[idx + 2] || 0
              bgra << b.chr << g.chr << r.chr << "\xFF".b
            else
              idx = x * 4
              b = bytes[idx] || 0
              g = bytes[idx + 1] || 0
              r = bytes[idx + 2] || 0
              a = bytes[idx + 3] || 255
              bgra << b.chr << g.chr << r.chr << a.chr
            end
          end
        end

        { width: width, height: height, bgra: bgra }
      rescue => e
        puts "[NDS-WIC] BMP 파싱 예외: #{e.message}"
        nil
      end

    end
  end
end