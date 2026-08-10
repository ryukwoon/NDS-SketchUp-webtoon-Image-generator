# encoding: utf-8
# ==============================================================================
# 파일명: NDS_WIC.rb
# 인코딩: UTF-8
# 설명: [NDS-WIC] 스케치업 확장 프로그램 루트 등록 파일 (v2.0.0)
# ==============================================================================

require 'sketchup.rb'
require 'extensions.rb'
require 'json'

# [코드 수정 시작 - v2.0.0: 버전 2.0.0 반영 및 NDS Studio 브랜드 변경]
module NDS_Extensions
  module NDS_WIC

    unless file_loaded?(__FILE__)
      file_loaded(__FILE__)

      version_file = File.join(File.dirname(__FILE__), 'version.json')
      ext_version = '2.0.0'
      if File.exist?(version_file)
        begin
          json_data = JSON.parse(File.read(version_file, encoding: 'UTF-8'))
          ext_version = json_data['version'] || '2.0.0'
        rescue => e
          puts "[NDS-WIC] version.json 로드 실패: #{e.message}"
        end
      end

      ext = SketchupExtension.new('NDS-WIC', 'NDS_WIC/NDS_WIC_menus.rb')
      ext.creator     = 'NDS Studio'
      ext.version     = ext_version
      ext.copyright   = '2022-2026, NDS Studio'
      ext.description = 'NDS-웹툰장면 생성기 (채널 생성 및 PSD 레이어 일괄 내보내기)'

      Sketchup.register_extension(ext, true)
    end

  end
end

file_loaded(__FILE__)
# [코드 수정 끝]