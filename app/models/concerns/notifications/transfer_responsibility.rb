module Notifications
  module TransferResponsibility
    extend ActiveSupport::Concern

    included do
      def self.transfer_responsibility(resource, old_entity, new_entity, extra_data = nil, acting_user: nil)
        notification_case = NotificationCase.find('transfer_responsibility')
        data = {
          resource: { link_def: { label: resource.title } },
          user: { fullname: old_entity.to_s }
        }
        if old_entity.is_a?(Delegation)
          data[:source_delegation] = { name: old_entity.name }
        else
          data[:source_user] = { fullname: old_entity.to_s }
        end
        data[:acting_user] = { fullname: acting_user.to_s } if acting_user.present?
        data = data.deep_merge(extra_data) if extra_data.present?

        if new_entity.is_a?(Delegation)
          new_entity.users_to_be_notified.each do |user|
            notify!(user, notification_case, data, new_entity)
          end
          if new_entity.notifications_email.present?
            notify!(nil, notification_case, data, new_entity)
          end
        else
          notify!(new_entity, notification_case, data)
        end
      end

      def self.notify!(user, notification_case, data, delegation = nil)
        beta_testing = if user and delegation
                         user.beta_tester_notifications? and delegation.beta_tester_notifications?
                       elsif user
                         user.beta_tester_notifications?
                       elsif delegation
                         delegation.beta_tester_notifications?
                       end

        if beta_testing
          ActiveRecord::Base.transaction do
            notif = create!(user: user,
                            notification_case_label: notification_case.label,
                            data: data,
                            via_delegation: delegation)
            if user and email = create_email_immediately_if_user_setting_commands!(
                user,
                notification_case,
                data
            )
              notif.update!(email_id: email.id)
            end
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
        tmpl_klass = NotificationCase::EMAIL_TEMPLATES[notification_case.label]

        app_setting = AppSetting.first
        lang = ( entity.try(:emails_locale) || app_setting.default_locale ).to_sym
        data = data.merge({ site_titles: app_setting.site_titles })

        tmpl_inst = tmpl_klass.new(data)
        subject = tmpl_inst.render_single_email_subject(lang)
        body = tmpl_inst.render_single_email(lang)

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
