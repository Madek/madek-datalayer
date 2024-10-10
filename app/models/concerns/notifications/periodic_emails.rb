module Notifications
  module PeriodicEmails
    extend ActiveSupport::Concern

    included do
      PERIODIC_EMAILS_BATCH_SIZE = 600

      scope :without_emails, -> { where(email_id: nil) }
      scope :for_daily_emails_delivery, -> {
        without_emails
          .with_user_settings
          .where(ntus: { email_frequency: email_frequency_with_fallback(:daily) })
          .where("notifications.created_at > current_date::timestamptz - interval '1 day'")
          .order('notifications.created_at DESC')
      }

      scope :for_weekly_emails_delivery, -> {
        without_emails
          .with_user_settings
          .where(ntus: { email_frequency: email_frequency_with_fallback(:weekly) })
          .where("notifications.created_at > current_date::timestamptz - interval '7 days'")
          .order('notifications.created_at DESC')
      }

      def self.produce_daily_emails
        produce_periodical_emails(for_daily_emails_delivery, :daily) 
      end

      def self.produce_weekly_emails
        produce_periodical_emails(for_weekly_emails_delivery, :weekly) 
      end

      def self.produce_periodical_emails(notifs, frequency)
        notifs.group_by(&:notification_case).each_pair do |notif_case, notifs_1|
          tmpl_mod = NotificationCase::EMAIL_TEMPLATES[notif_case.label]
          unless tmpl_mod
            Rails.logger.warn("No email templates module found for notification case: #{notif_case.label}.")
          end

          notifs_1.group_by(&:user).each_pair do |user, notifs_2|
            if user and notifs_2.size > 0
              batched(notifs_2) do |notifs_batch, batch_index|
                produce_summary_email(user, notifs_batch, tmpl_mod, frequency, batch_index)
              end
            elsif Madek::Constants::DEFAULT_DELEGATION_NOTIFICATIONS_EMAILS_FREQUENCY == frequency
              notifs_2.group_by(&:via_delegation).each_pair do |delegation, notifs_3|
                if notifs_3.size > 0
                  batched(notifs_3) do |notifs_batch, batch_index|
                    produce_summary_email(delegation, notifs_batch, tmpl_mod, frequency, batch_index) 
                  end
                end
              end
            end
          end
        end
      end

      def self.batched(notifs)
        notifs
          .sort_by { |n| n.via_delegation&.name || "" }
          .each_slice(PERIODIC_EMAILS_BATCH_SIZE).with_index do |batch, index|
          yield(batch, index)
        end
      end

      def self.produce_summary_email(recipient, notifs, tmpl_mod, frequency, batch_index)
        begin
          ActiveRecord::Base.transaction do 
            app_setting = AppSetting.first
            lang = (
              ( recipient.is_a?(User) and recipient.emails_locale ) or app_setting.default_locale 
            ).to_sym
            from_address = SmtpSetting.first.default_from_address
            to_address = if recipient.is_a?(User)
                           recipient.email 
                         else
                           recipient.notifications_email 
                         end

            subject = tmpl_mod.render_summary_email_subject(lang, { site_titles: app_setting.site_titles,
                                                                    email_frequency: frequency,
                                                                    batch_index: batch_index})
            body = tmpl_mod.render_summary_email(lang, { notifications: notifs,
                                                         site_titles: app_setting.site_titles,
                                                         external_base_url: Settings.madek_external_base_url,
                                                         my_settings_url: "#{Settings.madek_external_base_url}/my/settings",
                                                         support_email: Settings.madek_support_email,
                                                         provenance_notices: app_setting.provenance_notices,
                                                         email_frequency: frequency })

            email = Email.create!(user: recipient.is_a?(User) ? recipient : nil,
                                  delegation: recipient.is_a?(Delegation) ? recipient : nil,
                                  to_address: to_address,
                                  from_address: from_address,
                                  subject: subject,
                                  body: body)

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
