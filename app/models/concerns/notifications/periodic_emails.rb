module Notifications
  module PeriodicEmails
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

      # TODO: timespan: whole previous day until now
      def self.produce_daily_emails
        produce_periodical_emails(for_daily_emails_delivery, :daily) 
      end

      # TODO: timespan: whole previous week until now
      def self.produce_weekly_emails
        produce_periodical_emails(for_weekly_emails_delivery, :weekly) 
      end

      def self.produce_periodical_emails(notifs, frequency)
        # TODO: move to the sql query itself
        since_date = case frequency
                     when :daily
                       Date.yesterday.to_datetime
                     when :weekly
                       (Date.today - 7.days).to_datetime
                     end
        notifs = notifs.select { |n| n.created_at > since_date }

        notifs.group_by(&:notification_case).each_pair do |notif_case, notifs_1|
          tmpl_mod = NotificationCase::EMAIL_TEMPLATES[notif_case.label]
          unless tmpl_mod
            Rails.logger.warn("No email templates module found for notification case: #{notif_case.label}.")
          end

          notifs_1.group_by(&:user).each_pair do |user, notifs_2|
            if user and notifs_2.size > 0
              produce_summary_email(nil, user, notifs_2, tmpl_mod, frequency)
            elsif Madek::Constants::DEFAULT_DELEGATION_NOTIFICATIONS_EMAILS_FREQUENCY == frequency
              notifs_2.group_by(&:via_delegation).each_pair do |delegation, notifs_3|
                if notifs_3.size > 0
                  produce_summary_email(delegation, nil, notifs_3, tmpl_mod, frequency)
                end
              end
            end
          end
        end
      end

      def self.produce_summary_email(delegation, user, notifs, tmpl_mod, frequency)
        if delegation and user
          raise "Either delegation or user must be nil."
        end

        begin
          ActiveRecord::Base.transaction do 
            app_setting = AppSetting.first
            lang = ( user&.emails_locale || app_setting.default_locale ).to_sym
            subject = tmpl_mod.render_summary_email_subject(lang, { site_titles: app_setting.site_titles })
            body = tmpl_mod.render_summary_email(lang, { notifications: notifs,
                                                         site_titles: app_setting.site_titles,
                                                         external_base_url: Settings.madek_external_base_url,
                                                         my_settings_url: "#{Settings.madek_external_base_url}/my/settings",
                                                         support_email: Settings.madek_support_email,
                                                         provenance_notice: app_setting.provenance_notice,
                                                         email_frequency: frequency })
            from_address = SmtpSetting.first.default_from_address
            to_address = user&.email || delegation&.notifications_email

            email = Email.create!(user: user,
                                  delegation: delegation,
                                  subject: subject,
                                  body: body,
                                  from_address: from_address,
                                  to_address: to_address)

            notifs.each { |n| n.update!(email_id: email.id) }
          end
        rescue => e
          Rails.logger.warn("Error while producing summary email: #{e.message}")
        end
      end

      def self.email_frequency_with_fallback(freq)
        if Madek::Constants::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY == freq
          [freq, nil]
        else
          freq
        end
      end
    end
  end
end
