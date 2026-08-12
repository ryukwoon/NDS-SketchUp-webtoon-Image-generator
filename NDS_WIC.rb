# encoding: utf-8
# ==============================================================================
# 파일명: NDS_WIC.rb
# 설명: [NDS-WIC] 확장 프로그램 루트 등록 파일 (v2.1.1)
# ==============================================================================

require 'sketchup.rb'
require 'extensions.rb'
require 'json'
require_relative 'NDS_WIC/NDS_WIC_i18n'

module NDS_Extensions
  module NDS_WIC

    unless file_loaded?(__FILE__)
      file_loaded(__FILE__)

      ext_version = '2.1.1'

      ext = SketchupExtension.new(I18n.t('MENU_TITLE'), 'NDS_WIC/NDS_WIC_menus.rb')
      ext.creator     = 'NDS Studio'
      ext.version     = ext_version
      ext.copyright   = '2022-2026, NDS Studio'
      ext.description = I18n.t('EXT_DESCRIPTION')

      Sketchup.register_extension(ext, true)
    end

  end
end

file_loaded(__FILE__)