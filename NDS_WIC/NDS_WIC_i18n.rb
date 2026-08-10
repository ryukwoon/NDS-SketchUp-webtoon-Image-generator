# encoding: utf-8
# 파일명: NDS_WIC_i18n.rb

require 'json'
require 'sketchup.rb'

module NDS_Extensions
  module NDS_WIC
    module I18n
      @@current_lang = nil
      @@translations = {}
      @@available_langs = nil

      module_function

      # lang 폴더 내의 모든 .json 파일을 스캔하여 지원 언어 목록 생성
      def available_languages
        return @@available_langs if @@available_langs

        @@available_langs = {}
        base_path = File.dirname(__FILE__)
        lang_dir = File.join(base_path, 'lang')

        if Dir.exist?(lang_dir)
          Dir.glob(File.join(lang_dir, '*.json')).each do |file_path|
            lang_code = File.basename(file_path, '.json')
            begin
              json_text = File.read(file_path, encoding: 'UTF-8')
              data = JSON.parse(json_text)
              # json 파일 안의 LANG_NAME을 메뉴 이름으로 사용 (없으면 파일명 사용)
              display_name = data['LANG_NAME'] || lang_code.upcase
              @@available_langs[lang_code] = display_name
            rescue => e
              puts "[NDS-WIC] 언어 파일 스캔 실패 (#{lang_code}): #{e.message}"
            end
          end
        end

        # 언어 파일이 하나도 없을 경우 기본 값
        if @@available_langs.empty?
          @@available_langs['en'] = 'English'
        end

        @@available_langs
      end

      def current_language
        return @@current_lang if @@current_lang

        langs = available_languages
        saved_lang = Sketchup.read_default('NDS_WIC', 'Language', nil)

        if saved_lang && langs.key?(saved_lang)
          @@current_lang = saved_lang
        else
          locale = Sketchup.get_locale.to_s.downcase[0..1]
          @@current_lang = langs.key?(locale) ? locale : 'en'
        end

        load_translations(@@current_lang)
        @@current_lang
      end

      def set_language(lang_code)
        langs = available_languages
        return unless langs.key?(lang_code)

        @@current_lang = lang_code
        Sketchup.write_default('NDS_WIC', 'Language', lang_code)
        load_translations(lang_code)
      end

      def load_translations(lang_code)
        base_path = File.dirname(__FILE__)
        lang_file = File.join(base_path, 'lang', "#{lang_code}.json")

        unless File.exist?(lang_file)
          lang_file = File.join(base_path, 'lang', 'en.json')
        end

        if File.exist?(lang_file)
          begin
            json_text = File.read(lang_file, encoding: 'UTF-8')
            @@translations = JSON.parse(json_text)
          rescue => e
            puts "[NDS-WIC] 언어 로드 오류: #{e.message}"
            @@translations = {}
          end
        end
      end

      def t(key)
        current_language if @@translations.empty?
        @@translations[key.to_s] || key.to_s
      end

      def all_translations
        current_language if @@translations.empty?
        @@translations
      end
    end
  end
end