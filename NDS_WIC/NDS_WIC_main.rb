# encoding: utf-8
# ==============================================================================
# 파일명: NDS_WIC_main.rb
# 인코딩: UTF-8
# 설명: [NDS-WIC] 비동기 레이어 스트리밍 컨트롤러 (47개 중복 알림창 완벽 차단 수정판)
# ==============================================================================

require_relative 'NDS_WIC_psd'
require_relative 'NDS_WIC_i18n'

module NDS_Extensions
  module NDS_WIC
    class MainTool

      @@dialog = nil
      @@export_busy = false

      def initialize
        @path = File.dirname(__FILE__)
        @html_file = File.join(@path, 'NDS_WIC.html')
        @style_folder = File.join(@path, 'channels')

        unless File.exist?(@html_file)
          UI.messagebox("#{I18n.t('MSG_FILE_NOT_FOUND')}: #{@html_file}")
          return
        end

        show_dialog
      end

      private

      def show_dialog
        if @@dialog == nil
          @@dialog = UI::WebDialog.new(I18n.t("TITLE"), false, "NDS_WIC_Dialog", 640, 680, 100, 100, true)
          @@dialog.add_action_callback("push_frame") do |dialog, data|
            push_frame(dialog, data)
          end
        end

        @@dialog.set_size(640, 680)
        @@dialog.set_file(@html_file)
        
        @@dialog.show do
          send_i18n_data_to_html
        end
      end

      def send_i18n_data_to_html
        return unless @@dialog
        json_str = I18n.all_translations.to_json
        js_code = "if(typeof applyTranslations === 'function') { applyTranslations(#{json_str}); }"
        @@dialog.execute_script(js_code)
      end

      def push_frame(dialog, data)
        params = query_to_hash(data)
        action = params['action'].to_s

        if action == 'init_lang'
          send_i18n_data_to_html
        elsif action == 'create'
          execute_scene_creation(params)
          Sketchup.send_action('selectSelectionTool:')
        elsif action == 'export'
          execute_export(params)
          Sketchup.send_action('selectSelectionTool:')
        elsif action == 'close'
          Sketchup.send_action('selectSelectionTool:')
          @@dialog.close
        end
      end

      def update_ui_progress(percent, message)
        return unless @@dialog
        safe_msg = message.to_s.gsub("'", "\\'").gsub('"', '\\"')
        js_code = "if(typeof updateProgress === 'function') { updateProgress(#{percent.to_i}, '#{safe_msg}'); }"
        @@dialog.execute_script(js_code)
      end

      def execute_scene_creation(params)
        model = Sketchup.active_model
        pages = model.pages

        create_channel_scene(model, pages, "Alpha", "Alpha Style.style") if params['alpha'] == "true"
        create_channel_scene(model, pages, "Cley", "Cley Style.style", light: 50, dark: 15) if params['cley'] == "true"
        create_channel_scene(model, pages, "Color", "Color Style.style") if params['color'] == "true"
        create_channel_scene(model, pages, "Color by Layer", "Color by Layer Style.style") if params['colorbylayer'] == "true"
        create_channel_scene(model, pages, "Line", "Line Style.style") if params['line'] == "true"
        create_channel_scene(model, pages, "Profile", "Profile Style.style") if params['profile'] == "true"

        if params['shadow'] == "true"
          create_channel_scene(model, pages, "Shadow", "Shadow Style.style", shadow: true, light: 100, dark: 0)
        end

        create_channel_scene(model, pages, "Texture", "Texture Style.style") if params['texture'] == "true"
        create_channel_scene(model, pages, "Zdepth", "Zdepth Style.style", fog: true) if params['zdepth'] == "true"
        create_channel_scene(model, pages, "Vibration", "k_freepen001.style") if params['vibration'] == "true"

        UI.messagebox(I18n.t("MSG_CREATE_DONE"))
      end

      def create_channel_scene(model, pages, page_name, style_file, opts = {})
        model.shadow_info['DisplayShadows'] = opts[:shadow] || false
        model.shadow_info['UseSunForAllShading'] = true
        model.shadow_info['Light'] = opts[:light] || 0
        model.shadow_info['Dark'] = opts[:dark] || 100

        if opts[:fog]
          model.rendering_options['FogEndDist'] = 35.m
          model.rendering_options['DisplayFog'] = true
        else
          model.rendering_options['DisplayFog'] = false
        end

        page = pages.add(page_name)
        style_path = File.join(@style_folder, style_file)
        model.styles.add_style(style_path, true) if File.exist?(style_path)
        page.update
      end

      def execute_export(params)
        if @@export_busy
          puts "[NDS-WIC] Export in progress..."
          return
        end

        model = Sketchup.active_model
        if model.path.empty?
          UI.messagebox(I18n.t("MSG_SAVE_MODEL_FIRST"))
          return
        end

        folder = File.dirname(model.path)
        export_type = params['sel_type'].to_s.downcase
        width = params['getwidth'].to_i
        height = params['getheight'].to_i
        anti = (params['antialias'] == "true")
        trans = (params['transparent'] == "true")
        all_single = params['all_single'].to_s

        pages = model.pages
        target_pages = (all_single == 'all') ? pages.to_a : [pages.selected_page]

        if target_pages.compact.empty?
          UI.messagebox(I18n.t("MSG_NO_SCENES"))
          return
        end

        @@export_busy = true

        if export_type == 'psd'
          start_async_psd_export(model, target_pages, folder, width, height, anti, trans)
        else
          start_async_image_export(model, target_pages, folder, export_type, width, height, anti, trans)
        end
      end

      def start_async_psd_export(model, pages, folder, width, height, anti, trans)
        layers_data = []
        total_pages = pages.size
        current_idx = 0
        timer_id = nil

        sys_temp_dir = ENV['TEMP'] || ENV['TMP'] || 'C:/Windows/Temp'
        actual_w = width
        actual_h = height

        # 장면 전환 애니메이션 속도 0으로 설정 (고속 전환)
        options = model.options['PageOptions'] rescue {}
        old_transition = options['TransitionTime'] rescue 0
        options['TransitionTime'] = 0 rescue nil

        update_ui_progress(0, I18n.t("PROG_PREPARING_PSD"))

        process_proc = proc do
          UI.stop_timer(timer_id) if timer_id # 타이머 중복 방지

          if current_idx < total_pages
            page = pages[current_idx]
            page_num = current_idx + 1
            percent = ((current_idx.to_f / total_pages) * 80).to_i

            page_name = page.name.dup rescue "Scene"
            page_name.force_encoding("UTF-8") if page_name.respond_to?(:force_encoding)

            msg = "#{I18n.t('PROG_EXTRACTING')} (#{page_num}/#{total_pages}): #{page_name}"
            update_ui_progress(percent, msg)

            begin
              model.pages.selected_page = page
              model.active_view.refresh

              temp_file = File.join(sys_temp_dir, "nds_wic_temp_#{page.entityID}.png")
              keys = {
                :filename => temp_file,
                :width => width,
                :height => height,
                :antialias => anti,
                :transparent => trans
              }

              status = model.active_view.write_image(keys)

              if status && File.exist?(temp_file)
                raw_rgba = nil
                if defined?(Sketchup::ImageRep)
                  img_rep = Sketchup::ImageRep.new
                  img_rep.load_file(temp_file)
                  raw_rgba = img_rep.data
                  actual_w = img_rep.width
                  actual_h = img_rep.height
                else
                  bmp_info = PsdWriter.read_bmp_rgba(temp_file)
                  if bmp_info
                    raw_rgba = bmp_info[:rgba]
                    actual_w = bmp_info[:width]
                    actual_h = bmp_info[:height]
                  end
                end

                if raw_rgba && !raw_rgba.empty?
                  layers_data << {
                    :name => page_name,
                    :data => raw_rgba,
                    :width => actual_w,
                    :height => actual_h
                  }
                end

                File.delete(temp_file) rescue nil
              end
            rescue => e
              puts "[NDS-WIC] Scene extraction warning: #{e.message}"
            end

            current_idx += 1
            GC.start
            timer_id = UI.start_timer(0.05, false, &process_proc)
          else
            options['TransitionTime'] = old_transition rescue nil # 애니메이션 복원
            start_incremental_psd_build(model, folder, actual_w, actual_h, layers_data)
          end
        end

        timer_id = UI.start_timer(0.05, false, &process_proc)
      end

      def start_incremental_psd_build(model, folder, width, height, layers_data)
        psd_filename = "#{File.basename(model.path, '.skp')}_Channels.psd"
        psd_path = File.join(folder, psd_filename)
        tmp_path = "#{psd_path}.tmp"
        timer_id = nil
        export_finished = false

        num_layers = layers_data.size
        if num_layers == 0
          update_ui_progress(0, I18n.t("PROG_ERROR_NO_LAYER"))
          UI.messagebox(I18n.t("MSG_NO_LAYER_DATA"))
          @@export_busy = false
          return
        end

        begin
          f = File.open(tmp_path, 'wb')

          f.write('8BPS')
          f.write([1].pack('n'))
          f.write("\x00" * 6)
          f.write([3].pack('n'))
          f.write([height, width].pack('NN'))
          f.write([8].pack('n'))
          f.write([3].pack('n'))

          f.write([0].pack('N'))
          f.write([0].pack('N'))

          layer_records = []
          layer_channels_list = []

          layers_data.each do |layer|
            raw_rgba = layer[:data]
            layer_name = layer[:name] || 'Layer'
            layer_w = layer[:width] || width
            layer_h = layer[:height] || height

            chans = PsdWriter.extract_channels_fast(raw_rgba, layer_w, layer_h)
            layer_channels_list << chans

            channels = [
              { id: -1, size: chans[:a].bytesize },
              { id: 0,  size: chans[:r].bytesize },
              { id: 1,  size: chans[:g].bytesize },
              { id: 2,  size: chans[:b].bytesize }
            ]

            chan_info_bytes = ''
            channels.each do |ch|
              chan_info_bytes << [ch[:id], ch[:size] + 2].pack('nN')
            end

            name_bytes = layer_name.encode('UTF-8').b rescue layer_name.b
            name_pascal = [name_bytes.bytesize].pack('C') + name_bytes
            padding_len = (4 - (name_pascal.bytesize % 4)) % 4
            name_pascal << ("\x00" * padding_len)

            rec = String.new
            rec << [0, 0, layer_h, layer_w].pack('NNNN')
            rec << [4].pack('n')
            rec << chan_info_bytes
            rec << '8BIMnorm'
            rec << [255, 0, 0x09, 0].pack('CCCC')

            extra_block = [0].pack('N') + [0].pack('N') + name_pascal
            rec << [extra_block.bytesize].pack('N') + extra_block

            layer_records << rec
          end

          all_records_bytes = layer_records.join
          chan_data_total_bytes = num_layers * 4 * (2 + width * height)
          layer_info_len = 2 + all_records_bytes.bytesize + chan_data_total_bytes

          padding = (layer_info_len % 2 != 0) ? "\x00" : ""
          total_layer_section_len = 4 + layer_info_len + padding.bytesize

          f.write([total_layer_section_len].pack('N'))
          f.write([layer_info_len].pack('N'))
          f.write([num_layers].pack('n'))
          f.write(all_records_bytes)

          layer_idx = 0

          write_layer_proc = proc do
            UI.stop_timer(timer_id) if timer_id # 타이머 중복 방지

            if layer_idx < num_layers
              percent = 80 + (((layer_idx + 1).to_f / num_layers) * 15).to_i
              layer_obj = layers_data[layer_idx]
              msg = "#{I18n.t('PROG_BUILDING_PSD')} (#{layer_idx + 1}/#{num_layers}): #{layer_obj[:name]}"
              update_ui_progress(percent, msg)

              chans = layer_channels_list[layer_idx]
              f.write([0].pack('n') + chans[:a])
              f.write([0].pack('n') + chans[:r])
              f.write([0].pack('n') + chans[:g])
              f.write([0].pack('n') + chans[:b])

              layer_idx += 1
              GC.start
              timer_id = UI.start_timer(0.05, false, &write_layer_proc)
            else
              next if export_finished # 중복 방지
              export_finished = true

              f.write(padding) unless padding.empty?
              f.write([0].pack('n'))

              first_chans = layer_channels_list.first
              f.write(first_chans[:r])
              f.write(first_chans[:g])
              f.write(first_chans[:b])

              f.flush
              f.close

              File.delete(psd_path) if File.exist?(psd_path)
              File.rename(tmp_path, psd_path)

              layers_data.clear
              layer_channels_list.clear
              GC.start

              @@export_busy = false
              update_ui_progress(100, I18n.t("PROG_PSD_DONE"))

              # 단 1회만 실행되는 알림창
              UI.messagebox("#{I18n.t('MSG_EXPORT_PSD_DONE')}\n#{I18n.t('MSG_SAVED_PATH')}: #{folder}")
              UI.openURL("file:///#{folder}")
            end
          end

          timer_id = UI.start_timer(0.05, false, &write_layer_proc)

        rescue => e
          f.close rescue nil
          File.delete(tmp_path) if File.exist?(tmp_path)
          @@export_busy = false
          update_ui_progress(0, I18n.t("PROG_PSD_SAVE_ERROR"))
          puts "[NDS-WIC] PSD Error: #{e.message}"
          UI.messagebox("#{I18n.t('MSG_PSD_ERROR')}:\n#{e.message}")
        end
      end

      # 비동기 개별 이미지(PNG/JPG/BMP/TIFF) 내보내기 (중복 안내창 차단 적용)
      def start_async_image_export(model, pages, folder, export_type, width, height, anti, trans)
        total_pages = pages.size
        current_idx = 0
        timer_id = nil
        export_finished = false # 중복 완료 방지 플래그

        # 장면 전환 애니메이션 속도 0으로 설정 (고속 내보내기)
        options = model.options['PageOptions'] rescue {}
        old_transition = options['TransitionTime'] rescue 0
        options['TransitionTime'] = 0 rescue nil

        update_ui_progress(0, I18n.t("PROG_PREPARING_IMG"))

        process_proc = proc do
          UI.stop_timer(timer_id) if timer_id # 타이머 중복 누수 방지 (핵심)

          if current_idx < total_pages
            page = pages[current_idx]
            page_num = current_idx + 1
            percent = (((current_idx + 1).to_f / total_pages) * 100).to_i

            model.pages.selected_page = page
            model.active_view.refresh

            scene_name = page.name.gsub(/[^A-Za-z0-9_\-\uAC00-\uD7A3]/, '_')
            file_name = "#{File.basename(model.path, '.skp')}_#{scene_name}.#{export_type}"
            file_path = File.join(folder, file_name)

            msg = "#{I18n.t('PROG_SAVING_IMG')} (#{page_num}/#{total_pages}): #{scene_name}"
            update_ui_progress(percent, msg)

            keys = {
              :filename => file_path,
              :width => width,
              :height => height,
              :antialias => anti,
              :compression => 0.9,
              :transparent => trans
            }
            model.active_view.write_image(keys)

            current_idx += 1
            GC.start
            timer_id = UI.start_timer(0.05, false, &process_proc)
          else
            next if export_finished # 중복 진입 방지
            export_finished = true

            options['TransitionTime'] = old_transition rescue nil # 애니메이션 설정 복원

            @@export_busy = false
            update_ui_progress(100, I18n.t("PROG_IMG_DONE"))
            
            # 단 1회만 알림창 출력
            UI.messagebox("#{I18n.t('MSG_EXPORT_IMG_DONE')}\n#{I18n.t('MSG_SAVED_PATH')}: #{folder}")
            UI.openURL("file:///#{folder}")
          end
        end

        timer_id = UI.start_timer(0.05, false, &process_proc)
      end

      def unescape(string)
        return "" if string.nil?
        string.gsub(/\+/, ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/) do
          [$1.delete('%')].pack('H*')
        end
      end

      def query_to_hash(query)
        param_pairs = query.to_s.split('&')
        param_hash = {}
        for param in param_pairs
          name, value = param.split('=')
          name = unescape(name)
          value = unescape(value)
          param_hash[name] = value
        end
        param_hash
      end

    end
  end
end

file_loaded(__FILE__)