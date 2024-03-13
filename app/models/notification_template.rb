class NotificationTemplate < ApplicationRecord
  include Concerns::NotificationTemplates::Utils

  has_many(:users_settings,
           class_name: 'NotificationTemplateUserSetting',
           foreign_key: :notification_template_label)

  CATEGORIES = [:ui,
                :email_single,
                :email_single_subject,
                :email_summary,
                :email_summary_subject] 

  CATEGORIES.each do |category|
    define_method(category) do
      read_attribute(category).with_indifferent_access
    end

    define_method("render_#{category}") do |locale, data|
      render!(category, locale, data)
    end
  end

  validate do
    CATEGORIES.each do |tmpl_cat|
      [:de, :en].each do |lang|
        tmpl = self.send(tmpl_cat)[lang]
        lt = Liquid::Template.parse(tmpl, error_mode: :strict)
        vars = self.send("#{tmpl_cat}_vars")
        lt.render!(self.class.vars_stub(vars), strict_variables: true)
      end
    end
  end

  private

  def render!(category, locale, data)
    tmpl_string = send(category)[locale]
    tmpl = Liquid::Template.parse(tmpl_string)
    if tmpl.errors.present?
      tmpl.errors.each { |e| Rails.log.warn(e) }
    end
    tmpl.render!(data.deep_stringify_keys)
  end
end
