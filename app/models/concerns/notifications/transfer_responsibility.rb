module Concerns
  module Notifications
    module TransferResponsibility
      extend ActiveSupport::Concern

      included do
        def self.transfer_responsibility(resource, old_entity, new_entity, extra_data = nil)
          if new_entity.beta_tester_notifications?
            notification_case = NotificationCase.find('transfer_responsibility')
            data = {
              resource: { link_def: { label: resource.title } },
              user: { fullname: old_entity.to_s }
            }
            data = data.deep_merge(extra_data) if extra_data.present?

            if new_entity.is_a?(Delegation)
              new_entity.users_to_be_notified.each do |user|
                notify!(user, notification_case, data, new_entity)
              end
              if new_entity.notifications_email.present?
                create_email!(new_entity, notification_case, data)
              end
            else
              notify!(new_entity, notification_case, data)
            end
          end
        end

        def self.notify!(new_entity, notification_case, data, delegation = nil)
          ActiveRecord::Base.transaction do
            notif = create!(user: new_entity,
                            notification_case_label: notification_case.label,
                            data: data,
                            via_delegation: delegation)
            if email = create_email_immediately_if_user_setting_commands!(
                new_entity,
                notification_case,
                data
            )
              notif.update!(email_id: email.id)
            end
          end
        end

        def self.create_email_immediately_if_user_setting_commands!(user, notification_case, data)
          notif_tmpl_user_setting = \
            NotificationCaseUserSetting.find_by(notification_case_label: notification_case.label,
                                                user_id: user.id)

          if notif_tmpl_user_setting.try(:email_frequency) == 'immediately'
            if user.email
              create_email!(user, notification_case, data)
            else
              Rails.log.warn("User's email not specified. Email not sent.")
            end
          end
        end

        def self.create_email!(entity, notification_case, data)
          tmpl_mod = NotificationCase::EMAIL_TEMPLATES[notification_case.label]

          app_setting = AppSetting.first
          lang = app_setting.default_locale.to_sym
          subject = tmpl_mod.render_single_email_subject(lang, { site_titles: app_setting.site_titles })
          body = tmpl_mod.render_single_email(lang, data)
          from_address = SmtpSetting.first.default_from_address
          to_address = if entity.is_a?(Delegation)
                         entity.notifications_email
                       else
                         entity.email
                       end

          Email.create!(user_id: entity.is_a?(User) ? entity.id : nil,
                        delegation_id: entity.is_a?(Delegation) ? entity.id : nil,
                        subject: subject,
                        body: body,
                        from_address: from_address,
                        to_address: to_address)
        end
      end
    end
  end
end
