module EmailTemplates
  class TransferResponsibility
    class << self
      def render_single_email_subject(lang, data)
        data ||= {}
        site_titles = (data[:site_titles] || {}).with_indifferent_access

        tmpl = {
          en: "#{site_titles[:en]}: SINGLE EMAIL SUBJECT EN TODO",
          de: "#{site_titles[:de]}: Űbertragung der Verantwortlichkeit"
        }

        tmpl[lang.to_sym]
      end

      def render_single_email(lang, _data)
        txt = { en: "SINGLE EMAIL BODY EN TODO", de: "SINGLE EMAIL BODY DE TODO" }
        txt[lang.to_sym]
      end

      def render_summary_email_subject(lang, data)
        data ||= {}
        site_titles = (data[:site_titles] || {}).with_indifferent_access
        my_settings_url = data[:my_settings_url]

        txt = {
          en: "#{site_titles[:en]}: SUMMARY EMAIL SUBJECT EN TODO",
          de: "#{site_titles[:de]}: Zusammenfassung: Űbertragung der Verantwortlichkeit"
        }

        txt[lang.to_sym]
      end

      def render_summary_email(lang, data)
        data ||= {}
        notifications = data[:notifications] || [] 
        site_titles = data[:site_titles] || {}

        en_text = <<~TXT
          SUMMARY BODY EN TODO

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
        xs.sort_by { |x| x.via_delegation&.name || "" }
          .group_by(&:via_delegation)
          .map { |d, xs| section_per_delegation(d, xs)[lang] }
          .join("\n")
      end

      def section_per_delegation(delegation, xs)
        data = { size: xs.size }

        en_text = <<~TXT
          SECTION PER DELEGATION EN TODO
        TXT

        de_text = <<~TXT
          #{ via_delegation_title(delegation, data)[:de] }
          #{ dates_sections(:de, xs) }
        TXT

        { en: en_text, de: de_text }
      end

      def via_delegation_title(delegation, data)
        size = data[:size]
        en_text = "VIA DELEGATION TITLE EN TODO"
        de_text = if delegation
                    "Verantwortlichkeit übertragen an Verantwortungs-Gruppe #{delegation.name} (#{size})"
                  else
                    "Verantwortlichkeit an Sie übertragen (#{size})"
                  end

        { en: "VIA DELEGATION TITLE EN TODO",
          de: de_text }
      end

      def dates_sections(lang, xs)
        xs.sort_by { |x| x.created_at.to_i }
          .group_by { |x| x.created_at.to_date }
          .map { |d, xs| date_section(d, xs)[lang] }
          .join("")
      end

      def date_section(date, xs)
        en_text = <<~TXT
          * SECTION PER DATE EN TODO
        TXT

        de_text =
          if xs.size == 1
            " * #{ date.strftime('%d.%m.%Y') } - #{ single_event(xs.first)[:de] }"
          else
            <<~TXT
              * #{ date.strftime('%d.%m.%Y') }
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
          de: time + "Verantwortlichkeit für Set \"#{label}\" wurde von #{fullname} an #{delegation_name || 'Sie'} übertragen #{href}",
          en: time + "SINGLE EVEN TEMPLATE EN TODO"
        }
      end

      def personal_footer(data)
        data ||= {}
        site_titles = (data[:site_titles] || {}).with_indifferent_access
        my_settings_url = data[:my_settings_url]
        de_frequency = case data[:email_frequency]
                       when :daily then "täglich"
                       when :weekly then "wöchentlich"
                       end

        en_text = <<~TXT
          PERSONAL FOOTER EN TODO
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

        de_text = <<~TXT
          Haben Sie Fragen an den Support? Kontaktieren Sie mailto:#{support_email}.
          #{provenance_notice[:de]} #{external_base_url}
        TXT

        { de: de_text, en: "GENERAL FOOTER EN TODO" }
      end
    end
  end
end
