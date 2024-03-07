class Notification < ApplicationRecord
  belongs_to(:user)
  belongs_to(:email, optional: true)
  belongs_to(:notification_template, foreign_key: :notification_template_label)

  def data
    read_attribute(:data).with_indifferent_access
  end

  def self.transfer_responsibility(resource, old_entity, new_entity, extra_data)
    if old_entity.is_a?(Delegation) or new_entity.is_a?(Delegation)
      Rails.logger.info("Notification 'transfer_responsibility' for delegation not implemented yet.")
    else
      notification_template = NotificationTemplate.find('transfer_responsibility')
      data = {
        resource_link_def: { label: resource.title },
        user: { fullname: old_entity.to_s }
      }
      data = data.deep_merge(extra_data) if extra_data.present?

      ActiveRecord::Base.transaction do
        notif = create!(user: new_entity,
                        notification_template_label: notification_template.label,
                        data: data)

        notif_tmpl_user_setting = \
          NotificationTemplateUserSetting.find_by_notification_template_label('transfer_responsibility')

        if notif_tmpl_user_setting.try(:email_frequency) == 'immediately'
          if new_entity.email
            body = notif.render_single_email(:en)
            email = Email.create!(user_id: new_entity.id,
                                  subject: "Madek: transfer responsibility",
                                  body: body,
                                  from_address: SmtpSetting.first.default_from_address,
                                  to_address: new_entity.email)
            notif.update!(email_id: email.id)
          else
            Rails.log.warn("User's email not specified. Email not sent.")
          end
        end
      end
    end
  end

  NotificationTemplate::CATEGORIES.each do |category|
    define_method("render_#{category}") do |locale, strict: false|
      render!(category, locale, self.data, strict: strict)
    end
  end

  private

  def render!(category, locale, data, strict: false)
    tmpl_string = self.notification_template.send(category)[locale]
    error_mode = ( strict ? :error : :warn )
    tmpl = Liquid::Template.parse(tmpl_string, error_mode: error_mode)
    if tmpl.errors.present?
      tmpl.errors.each { |e| Rails.log.warn(e) }
    end
    tmpl.render!(data, strict_variables: strict)
  end
end
