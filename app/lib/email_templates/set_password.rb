module EmailTemplates
  class SetPassword
    def initialize(data)
      @data = data
      site_titles = (@data[:site_titles] || {}).with_indifferent_access
      @site_title = {
        de: site_titles[:de],
        en: (site_titles[:en].presence or site_titles[:de])
      }
      @external_base_url = @data[:external_base_url] 
      @reset_link = @data[:reset_link]
    end

    def render_subject(locale)
      txt = {
        en: "#{@site_title[:en]}: set password for your account",
        de: "#{@site_title[:de]}: Passwort setzen"
      }

      txt[locale]
    end

    def render_body(locale)
      en_text = <<~TXT
        Hello, 

        Your user account on #{@site_title[:en]} has been opened.  

        To set the password click on this link: 

        #{@reset_link}

        and foolow the instructions on the website.

        #{general_footer(:en)}
      TXT

      de_text = <<~TXT
        Guten Tag,

        Ihr neues Benutzerkonto für #{@site_title[:de]} wurde erstellt. 

        Um Ihr Passwort zu setzen, öffnen Sie folgenden Link:

        #{@reset_link}

        und folgen Sie den Instruktionen auf der Website. 

        #{general_footer(:de)}
      TXT

      txt = { en: en_text, de: de_text }
      txt[locale]
    end

    def general_footer(locale)
      en_text = <<~TXT
        #{@site_title[:en]}
        #{@external_base_url}
      TXT

      de_text = <<~TXT
        #{@site_title[:de]}
        #{@external_base_url}
      TXT

      { de: de_text, en: en_text }[locale]
    end
  end
end
