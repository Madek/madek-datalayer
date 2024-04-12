module Concerns
  module Notifications
    module TransferResponsibility
      extend ActiveSupport::Concern

      included do
        def self.transfer_responsibility(resource, old_entity, new_entity, extra_data = nil)
          if new_entity.beta_tester_notifications?
            if old_entity.is_a?(Delegation) or new_entity.is_a?(Delegation)
              Rails.logger.info("Notification 'transfer_responsibility' for delegation not implemented yet.")
            else
              notification_case = NotificationCase.find('transfer_responsibility')
              data = {
                resource: { link_def: { label: resource.title } },
                user: { fullname: old_entity.to_s }
              }
              data = data.deep_merge(extra_data) if extra_data.present?

              ActiveRecord::Base.transaction do
                notif = create!(user: new_entity,
                                notification_case_label: notification_case.label,
                                data: data)
                
                notif_tmpl_user_setting = \
                  NotificationCaseUserSetting.find_by_notification_case_label(notification_case.label)

                if notif_tmpl_user_setting.try(:email_frequency) == 'immediately'
                  if new_entity.email
                    tmpl_mod = NotificationCase::EMAIL_TEMPLATES[notification_case.label]

                    app_setting = AppSetting.first
                    lang = app_setting.default_locale.to_sym
                    subject = tmpl_mod.render_single_email_subject(lang, { site_titles: app_setting.site_titles })
                    body = tmpl_mod.render_single_email(lang, data)
                    from_address = SmtpSetting.first.default_from_address

                    email = Email.create!(user_id: new_entity.id,
                                          subject: subject,
                                          body: body,
                                          from_address: from_address,
                                          to_address: new_entity.email)

                    notif.update!(email_id: email.id)
                  else
                    Rails.log.warn("User's email not specified. Email not sent.")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
