module EmailTemplates
  class TransferResponsibility
    def initialize(data)
      @data = data || {}
      @my_settings_url = @data[:my_settings_url]
      @frequency = {
        de: case @data[:email_frequency]
            when :daily
              "tägliche"
            when :weekly
              "wöchentliche"
            end,
        en: case @data[:email_frequency]
            when :daily
              "daily"
            when :weekly
              "weekly"
            end
      }
      site_titles = (@data[:site_titles] || {}).with_indifferent_access
      @site_title = {
        de: site_titles[:de],
        en: (site_titles[:en].presence or site_titles[:de])
      }
      @notifications = @data[:notifications] || [] 
      @external_base_url = @data[:external_base_url] 
      @support_email = @data[:support_email]
      provenance_notices = @data[:provenance_notices] || {}
      @provenance_notice = {
        de: provenance_notices[:de],
        en: (provenance_notices[:en].presence or provenance_notices[:de])
      }
    end

    def render_summary_email_subject(lang)
      batch_en = if @data[:batch_index] > 0
                   " (part #{@data[:batch_index] + 1})"
                 end
      batch_de = if @data[:batch_index] > 0
                   " (Teil #{@data[:batch_index] + 1})"
                 end

      txt = {
        en: "#{@site_title[:en]}: #{@frequency[:en]} summary of responsibility transfers#{batch_en}",
        de: "#{@site_title[:de]}: #{@frequency[:de]} Zusammenfassung der Verantwortlichkeits-Übertragungen#{batch_de}"
      }

      txt[lang.to_sym]
    end

    def render_summary_email(lang)
      en_text = <<~TXT
        Hello 
        Notifications from #{@site_title[:en]}

        Responsibility transfers that concern you:

        #{delegations_sections(:en)}

        #{personal_footer[:en]}

        #{general_footer[:en]}
      TXT

      de_text = <<~TXT
        Guten Tag
        Notifikationen von #{@site_title[:de]}

        űbertragene Verantwortlichkeiten, die Sie betreffen:

        #{delegations_sections(:de)}

        #{personal_footer[:de]}

        #{general_footer[:de]}
      TXT

      txt = { en: en_text, de: de_text }
      txt[lang.to_sym]
    end

    def delegations_sections(lang)
      @notifications
        .group_by(&:via_delegation)
        .map { |d, xs| section_per_delegation(d, xs)[lang] }
        .join("\n")
    end

    def section_per_delegation(delegation, xs)
      opts = { size: xs.size }

      en_text = <<~TXT
        #{ via_delegation_title(delegation, opts)[:en] }
        #{ dates_sections(:en, xs) }
      TXT

      de_text = <<~TXT
        #{ via_delegation_title(delegation, opts)[:de] }
        #{ dates_sections(:de, xs) }
      TXT

      { en: en_text, de: de_text }
    end

    def via_delegation_title(delegation, opts)
      size = opts[:size]
      en_text = if delegation
                  "Responsability transfer to delegation #{delegation.name} (#{size})"
                else
                  "Responsability transfer to You (#{size})"
                end
      de_text = if delegation
                  "Verantwortlichkeit übertragen an Verantwortungs-Gruppe #{delegation.name} (#{size})"
                else
                  "Verantwortlichkeit an Sie übertragen (#{size})"
                end

      { en: en_text, de: de_text }
    end

    def dates_sections(lang, xs)
      xs
        .sort_by { |x| x.created_at.to_i }
        .group_by { |x| x.created_at.to_date }
        .map { |d, xs| date_section(d, xs)[lang] }
        .join("")
    end

    def date_section(date, xs)
      en_date_format = '%Y-%m-%d'
      en_text = 
        if xs.size == 1
          "* #{ date.strftime(en_date_format) } - #{ single_event(xs.first)[:en] }"
        else
          <<~TXT
            * #{ date.strftime(en_date_format) }
            #{ xs.map { |x| single_event(x, with_time: true)[:en] }.join("\n") }
          TXT
        end

      de_date_format = '%d.%m.%Y'
      de_text =
        if xs.size == 1
          "* #{ date.strftime(de_date_format) } - #{ single_event(xs.first)[:de] }"
        else
          <<~TXT
            * #{ date.strftime(de_date_format) }
            #{ xs.map { |x| single_event(x, with_time: true)[:de] }.join("\n") }
          TXT
        end

      { en: en_text, de: de_text }
    end

    def single_event(notif, with_time: false)
      data = (notif.data || {}).with_indifferent_access
      href = data.dig(:resource, :link_def, :href)
      label = data.dig(:resource, :link_def, :label)
      fullname = data.dig(:user, :fullname)
      source_delegation_name = data.dig(:source_delegation, :name)
      acting_user_name = data.dig(:acting_user, :fullname)
      source_name = source_delegation_name || fullname
      delegation_name = notif.via_delegation&.name
      time = with_time ? "  * #{ notif.created_at.strftime('%H:%M') } - " : ""
      to_part_en = delegation_name || 'You'
      to_part_de = delegation_name || 'Sie'
      from_part_en = if source_delegation_name.present? && acting_user_name.present?
                       "#{source_name} by #{acting_user_name}"
                     else
                       source_name
                     end
      from_part_de = if source_delegation_name.present? && acting_user_name.present?
                       "#{source_name} durch #{acting_user_name}"
                     else
                       source_name
                     end

      {
        en: time + "Responsability for \"#{label}\" has been transfered from #{from_part_en} to #{to_part_en} #{@external_base_url}#{href}",
        de: time + "Verantwortlichkeit für \"#{label}\" wurde von #{from_part_de} an #{to_part_de} übertragen #{@external_base_url}#{href}"
      }
    end

    def personal_footer
      en_text = <<~TXT
        You are getting this email due to Your settings in #{@site_title[:en]}: #{@my_settings_url}
        Your chosen email frequency for notifications: #{@frequency[:en]}
        You can change the settings personally.
      TXT

      de_text = <<~TXT
        Diese E-Mail bekommen Sie entsprechend Ihrer Einstellungen im #{@site_title[:de]}: #{@my_settings_url}
        Die von Ihnen gewählte Häufigkeit für E-Mail-Notifikationen: #{@frequency[:de]}
        Änderungen Ihrer Einstellungen können Sie selbständig vornehmen.
      TXT

      { en: en_text, de: de_text }
    end

    def general_footer
      en_text = <<~TXT
        Do You have any questions to the support? Contact mailto:#{@support_email}.
        #{@provenance_notice[:en]} #{@external_base_url}
      TXT

      de_text = <<~TXT
        Haben Sie Fragen an den Support? Kontaktieren Sie mailto:#{@support_email}.
        #{@provenance_notice[:de]} #{@external_base_url}
      TXT

      { de: de_text, en: en_text }
    end
  end
end
