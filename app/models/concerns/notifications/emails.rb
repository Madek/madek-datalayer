module Concerns
  module Notifications
    module Emails
      extend ActiveSupport::Concern

      included do

        scope :without_emails, -> { where(email_id: nil) }
        scope :for_daily_emails_delivery, -> {
          without_emails
            .with_user_settings
            .where(ntus: { email_frequency: email_frequency_with_fallback(:daily) })
            .order('notifications.created_at DESC')
        }

        scope :for_weekly_emails_delivery, -> {
          without_emails
            .with_user_settings
            .where(ntus: { email_frequency: email_frequency_with_fallback(:weekly) })
            .order('notifications.created_at DESC')
        }

        def self.produce_daily_emails
          produce_periodical_emails(for_daily_emails_delivery) 
        end

        def self.produce_weekly_emails
          produce_periodical_emails(for_weekly_emails_delivery) 
        end

        def self.produce_periodical_emails(notifs)
          notifs.group_by(&:user).each_pair do |user, notifs_1|
            notifs_1.group_by(&:notification_template).each_pair do |notif_tmpl, notifs_2|
              ActiveRecord::Base.transaction do 
                app_setting = AppSetting.first
                lang = app_setting.default_locale
                site_title = app_setting.site_title(lang)
                subject = notif_tmpl.render_email_summary_subject(lang, { site_title: site_title })
                body = notif_tmpl.render_email_summary(lang, prepare_summary_data(notifs_2))
                from_address = SmtpSetting.first.default_from_address

                email = Email.create!(user: user,
                                      subject: subject,
                                      body: body,
                                      from_address: from_address,
                                      to_address: user.email)

                notifs_2.each { |n| n.update!(email_id: email.id) }
              end
            end
          end
        end

        def self.prepare_summary_data(notifs)
          { collection: notifs.map(&:data) }
        end

        def self.email_frequency_with_fallback(freq)
          if Madek::Constants::Webapp::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY == freq
            [freq, nil]
          else
            freq
          end
        end

      end
    end
  end
end
