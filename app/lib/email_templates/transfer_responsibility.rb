module EmailTemplates
  class TransferResponsibility
    class << self
      def render_summary_email_subject(lang, data)
        data ||= {}
        site_titles = (data[:site_titles] || {}).with_indifferent_access
        my_settings_url = data[:my_settings_url]
        frequency_de = case data[:email_frequency]
                       when :daily
                         "tägliche"
                       when :weekly
                         "wöchentliche"
                       end
        frequency_en = case data[:email_frequency]
                       when :daily
                         "daily"
                       when :weekly
                         "weekly"
                       end
        batch_en = if data[:batch_index] > 0
                     " (part #{data[:batch_index] + 1})"
                   end
        batch_de = if data[:batch_index] > 0
                     " (Teil #{data[:batch_index] + 1})"
                   end

        txt = {
          en: "#{site_titles[:en]}: #{frequency_en} summary of responsibility transfers#{batch_en}",
          de: "#{site_titles[:de]}: #{frequency_de} Zusammenfassung der Verantwortlichkeits-Übertragungen#{batch_de}"
        }

        txt[lang.to_sym]
      end

      def render_summary_email(lang, data)
        data ||= {}
        notifications = data[:notifications] || [] 
        site_titles = data[:site_titles] || {}

        en_text = <<~TXT
          Hello 
          Notifications from #{site_titles[:en]}

          Responsibility transfers that concern you:

          #{ delegations_sections(:en, notifications) }

          #{personal_footer(data)[:en]}

          #{general_footer(data)[:en]}
        TXT

        de_text = <<~TXT
          Guten Tag
          Notifikationen von #{site_titles[:de]}

          űbertragene Verantwortlichkeiten, die Sie betreffen:

          #{ delegations_sections(:de, notifications) }

          #{ personal_footer(data)[:de] }

          #{ general_footer(data)[:de] }
        TXT

        txt = { en: en_text, de: de_text }
        txt[lang.to_sym]
      end

      def delegations_sections(lang, xs)
        xs.group_by(&:via_delegation)
          .map { |d, xs| section_per_delegation(d, xs)[lang] }
          .join("\n")
      end

      def section_per_delegation(delegation, xs)
        data = { size: xs.size }

        en_text = <<~TXT
          #{ via_delegation_title(delegation, data)[:en] }
          #{ dates_sections(:en, xs) }
        TXT

        de_text = <<~TXT
          #{ via_delegation_title(delegation, data)[:de] }
          #{ dates_sections(:de, xs) }
        TXT

        { en: en_text, de: de_text }
      end

      def via_delegation_title(delegation, data)
        size = data[:size]
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
        xs.sort_by { |x| x.created_at.to_i }
          .group_by { |x| x.created_at.to_date }
          .map { |d, xs| date_section(d, xs)[lang] }
          .join("")
      end

      def date_section(date, xs)
        en_date_format = '%Y-%m-%d'
        en_text = 
          if xs.size == 1
            " * #{ date.strftime(en_date_format) } - #{ single_event(xs.first)[:en] }"
          else
            <<~TXT
              * #{ date.strftime(en_date_format) }
              #{ xs.map { |x| single_event(x, with_time: true)[:en] }.join("\n") }
            TXT
          end

        de_date_format = '%d.%m.%Y'
        de_text =
          if xs.size == 1
            " * #{ date.strftime(de_date_format) } - #{ single_event(xs.first)[:de] }"
          else
            <<~TXT
              * #{ date.strftime(de_date_format) }
              #{ xs.map { |x| single_event(x, with_time: true)[:de] }.join("\n") }
            TXT
          end

        { en: en_text, de: de_text }
      end

      def single_event(notif, with_time: false)
        data = notif.data || {}
        href = data[:resource]&.[](:link_def)&.[](:href)
        label = data[:resource]&.[](:link_def)&.[](:label)
        fullname = data[:user]&.[](:fullname)
        delegation_name = notif.via_delegation&.name
        time = with_time ? "  * #{ notif.created_at.strftime('%H:%M') } - " : ""

        {
          en: time + "Responsability for \"#{label}\" has been transfered from #{fullname} to #{delegation_name || 'You'} #{href}",
          de: time + "Verantwortlichkeit für \"#{label}\" wurde von #{fullname} an #{delegation_name || 'Sie'} übertragen #{href}"
        }
      end

      def personal_footer(data)
        data ||= {}
        site_titles = (data[:site_titles] || {}).with_indifferent_access
        my_settings_url = data[:my_settings_url]
        en_frequency = case data[:email_frequency]
                       when :daily then "daily"
                       when :weekly then "weekly"
                       end
        de_frequency = case data[:email_frequency]
                       when :daily then "täglich"
                       when :weekly then "wöchentlich"
                       end

        en_text = <<~TXT
          You are getting this email due to Your settings in #{site_titles[:en]}: #{my_settings_url}
          Your chosen email frequency for notifications: #{en_frequency}
          You can change the settings personally.
        TXT

        de_text = <<~TXT
          Diese E-Mail bekommen Sie entsprechend Ihrer Einstellungen im #{site_titles[:de]}: #{my_settings_url}
          Die von Ihnen gewählte Häufigkeit für E-Mail-Notifikationen: #{de_frequency}
          Änderungen Ihrer Einstellungen können Sie selbständig vornehmen.
        TXT

        { en: en_text, de: de_text }
      end

      def general_footer(data)
        data ||= {}
        provenance_notice = data[:provenance_notice] || {}
        support_email = data[:support_email]
        external_base_url = data[:external_base_url]

        en_text = <<~TXT
          Do You have any questions to the support? Contact mailto:#{support_email}.
          #{provenance_notice[:en]} #{external_base_url}
        TXT

        de_text = <<~TXT
          Haben Sie Fragen an den Support? Kontaktieren Sie mailto:#{support_email}.
          #{provenance_notice[:de]} #{external_base_url}
        TXT

        { de: de_text, en: en_text }
      end
    end
  end
end
