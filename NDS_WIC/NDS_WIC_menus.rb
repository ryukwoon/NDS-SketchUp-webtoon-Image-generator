# encoding: utf-8
# 파일명: NDS_WIC_menus.rb

require 'sketchup.rb'
require_relative 'NDS_WIC_i18n'
require_relative 'NDS_WIC_main'

module NDS_Extensions
  module NDS_WIC

    if !file_loaded?('NDS_WIC_menu_loader')
      plugins_menu = UI.menu("Plugins")
      # 최상위 서브메뉴 이름 번역 적용
      @@NDS_tools_menu = plugins_menu.add_submenu(I18n.t("MENU_TITLE"))
    end

    if !file_loaded?(__FILE__)
      # 1. 메인 실행 메뉴
      @@NDS_tools_menu.add_item(I18n.t("MENU_TITLE")) {
        NDS_Extensions::NDS_WIC::MainTool.new
      }

      @@NDS_tools_menu.add_separator

      # 2. 언어 선택 서브메뉴
      lang_menu = @@NDS_tools_menu.add_submenu(I18n.t("MENU_LANG"))
      
      I18n.available_languages.each do |code, name|
        item = lang_menu.add_item(name) {
          I18n.set_language(code)
          
          # 언어 변경 알림 문구 다국어 불러오기
          msg_template = I18n.t("MSG_LANG_CHANGED")
          msg = msg_template.gsub("%{name}", name)
          
          UI.messagebox(msg)
        }
        lang_menu.set_validation_proc(item) {
          (I18n.current_language == code) ? MF_CHECKED : MF_UNCHECKED
        }
      end

      @@NDS_tools_menu.add_separator

      # 3. 블로그 및 깃허브 링크 (번역 적용 완료)
      @@NDS_tools_menu.add_item(I18n.t("MENU_BLOG")) {
        UI.openURL('https://blog.naver.com/kwoon1004')
      }
      @@NDS_tools_menu.add_item(I18n.t("MENU_GITHUB")) {
        UI.openURL('https://github.com/ryukwoon')
      }

      # 4. 툴바
      toolbar = UI::Toolbar.new("NDS-WIC")
      cmd_main = UI::Command.new(I18n.t("MENU_TITLE")) {
        NDS_Extensions::NDS_WIC::MainTool.new
      }
      cmd_main.small_icon = "img/TooN_suexport_1_16.png"
      cmd_main.large_icon = "img/TooN_suexport_1_24.png"
      cmd_main.tooltip = I18n.t("MENU_TITLE")
      cmd_main.status_bar_text = I18n.t("TITLE")
      
      toolbar.add_item(cmd_main)
      toolbar.show if toolbar.get_last_state != 0
    end

    file_loaded('NDS_WIC_menu_loader')
    file_loaded(__FILE__)
  end
end