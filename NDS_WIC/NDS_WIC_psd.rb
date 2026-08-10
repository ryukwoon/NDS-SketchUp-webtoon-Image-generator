# encoding: utf-8
# ==============================================================================
# 파일명: NDS_WIC_psd.rb
# 인코딩: UTF-8
# 설명: [NDS-WIC] C-Speed 고속 채널 분리 및 PSD 패커 (v2.4.0)
# ==============================================================================

module NDS_Extensions
  module NDS_WIC
    module PsdWriter
      module_function

      # [코드 수정 시작 - v2.4.0: C-Speed 고속 채널 분리 파서]
      def extract_channels_fast(raw_rgba, width, height)
        pixel_count = width * height
        all_bytes = raw_rgba.unpack('C*')
        len = all_bytes.size

        r_arr = Array.new(pixel_count)
        g_arr = Array.new(pixel_count)
        b_arr = Array.new(pixel_count)
        a_arr = Array.new(pixel_count)

        j = 0
        i = 0
        while i < len
          r_arr[j] = all_bytes[i] || 0
          g_arr[j] = all_bytes[i + 1] || 0
          b_arr[j] = all_bytes[i + 2] || 0
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
      # [코드 수정 끝]

      def read_bmp_rgba(bmp_path)
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

        rgba = String.new(capacity: width * height * 4)

        (height - 1).downto(0) do |y|
          row_start = y * row_bytes
          row = pixel_data[row_start, row_bytes]
          next if row.nil?

          bytes = row.unpack('C*')
          0.upto(width - 1) do |x|
            if bpp == 24
              idx = x * 3
              r = bytes[idx + 2] || 0
              g = bytes[idx + 1] || 0
              b = bytes[idx] || 0
              rgba << r.chr << g.chr << b.chr << "\xFF".b
            else
              idx = x * 4
              r = bytes[idx + 2] || 0
              g = bytes[idx + 1] || 0
              b = bytes[idx] || 0
              a = bytes[idx + 3] || 255
              rgba << r.chr << g.chr << b.chr << a.chr
            end
          end
        end

        { width: width, height: height, rgba: rgba }
      rescue => e
        puts "[NDS-WIC] BMP 파싱 예외: #{e.message}"
        nil
      end

    end
  end
end