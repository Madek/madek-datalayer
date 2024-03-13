class CreateNotificationFirstTemplatePart2 < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  class MigrationNotificationTemplate < ActiveRecord::Base
    self.table_name = 'notification_templates'
  end

  def up
    MigrationNotificationTemplate.find('transfer_responsibility').destroy!

    email_summary_en = <<~BODY
      Summary:{% for data in collection %}
        * Responsibility for <a href='{{ data.resource.link_def.href }}'>{{ data.resource.link_def.label }}</a> has been transfered to you from {{ data.user.fullname }}.{% endfor %}
    BODY
    email_summary_de = <<~BODY
      Zusammenfassung:{% for data in collection %}
        * Verantwortlichkeit von <a href='{{ data.resource.link_def.href }}'>{{ data.resource.link_def.label }}</a> wurde von {{ data.user.fullname }} an Sie übertragen.{% endfor %}
    BODY

    MigrationNotificationTemplate.create(
      label: 'transfer_responsibility',
      description: 'Notification to be sent when responsibility for an entry or set is transfered to another user or a delegation.',

      ui: { en: "Responsibility for <a href='{{ resource.link_def.href }}'>{{ resource.link_def.label }}</a> has been transfered to you from {{ user.fullname }}.",
            de: "Verantwortlichkeit von <a href='{{ resource.link_def.href }}'>{{ resource.link_def.label }}</a> wurde von {{ user.fullname }} an Sie übertragen." },
      ui_vars: ['resource.link_def.label', 'resource.link_def.href', 'user.fullname'],

      email_single_subject: { en: '{{ site_title }}: Transfer of responsability',
                              de: '{{ site_title }}: Űbertragung der Verantwortlichkeit' },
      email_single_subject_vars: ['site_title'],

      email_single: { en: "Responsibility for <a href='{{ resource.link_def.href }}'>{{ resource.link_def.label }}</a> has been transfered to you from {{ user.fullname }}.",
                      de: "Verantwortlichkeit von <a href='{{ resource.link_def.href }}'>{{ resource.link_def.label }}</a> wurde von {{ user.fullname }} an Sie übertragen." },
      email_single_vars: ['resource.link_def.label', 'resource.link_def.href', 'user.fullname'],

      email_summary_subject: { en: '{{ site_title }}: Summary: Transfer of responsability',
                               de: '{{ site_title }}: Zusammenfassung: Űbertragung der Verantwortlichkeit' },
      email_summary_subject_vars: ['site_title'],

      email_summary: { en: email_summary_en,
                       de: email_summary_de },
      email_summary_vars: ['collection', 'data.resource.link_def.label', 'data.resource.link_def.href', 'data.user.fullname']
    )
  end

  def down
  end
end
