module EmailTemplates
  class TransferResponsibility
    class << self
      def render_single_email_subject(lang, data)
        site_titles = data&.[](:site_titles).try(:with_indifferent_access)

        tmpl = {
          en: "#{site_titles[:en]}: Transfer of responsability",
          de: "#{site_titles[:de]}: Űbertragung der Verantwortlichkeit"
        }

        tmpl[lang.to_sym]
      end

      def render_single_email(lang, data)
        single_event_template(data)[lang.to_sym]
      end

      def render_summary_email_subject(lang, data)
        site_titles = data&.[](:site_titles).try(:with_indifferent_access)

        txt = {
          en: "#{site_titles[:en]}: Summary: Transfer of responsability",
          de: "#{site_titles[:de]}: Zusammenfassung: Űbertragung der Verantwortlichkeit"
        }

        txt[lang.to_sym]
      end

      def render_summary_email(lang, data)
        collection = data&.[](:collection) 

        summary = {
          en: collection.map { |el| "* #{single_event_template(el)[:en]}" }.join("\n"),
          de: collection.map { |el| "* #{single_event_template(el)[:de]}" }.join("\n")
        }

        en_text = <<-TXT
              Summary:
                #{summary[:en]}
        TXT
        de_text = <<-TXT
              Zusammenfassung:
                #{summary[:de]}
        TXT

        txt = { en: en_text, de: de_text }
        txt[lang.to_sym]
      end

      def single_event_template(data)
        href = data&.[](:resource)&.[](:link_def)&.[](:href)
        label = data&.[](:resource)&.[](:link_def)&.[](:label)
        fullname = data&.[](:user)&.[](:fullname)

        {
          de: "Verantwortlichkeit von <a href='#{href}'>#{label}</a> wurde von #{fullname} an Sie übertragen.",
          en: "Responsibility for <a href='#{href}'>#{label}</a> has been transfered to you from #{fullname}."
        }
      end
    end
  end
end
