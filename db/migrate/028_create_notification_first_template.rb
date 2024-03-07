class CreateNotificationFirstTemplate < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  class MigrationNotificationTemplate < ActiveRecord::Base
    self.table_name = 'notification_templates'
  end

  def up
    MigrationNotificationTemplate.create(
      label: 'transfer_responsibility',
      description: 'Notification to be sent when responsibility for an entry or set is transfered to another user or a delegation.',
      ui: { en: 'Responsibility for {{ resource_link_def }} has been transfered to you from {{ user.fullname }}.',
            de: 'Verantwortlichkeit von {{ resource_link_def }} wurde von {{ user.fullname }} an Sie übertragen.' },
      ui_vars: ['resource_link_def', 'user.fullname'],
      email_single: { en: 'Responsibility for {{ resource_link_def }} has been transfered to you from {{ user.fullname }}.',
                      de: 'Verantwortlichkeit von {{ resource_link_def }} wurde von {{ user.fullname }} an Sie übertragen.' },
      email_single_vars: ['resource_link_def', 'user.fullname'],
      email_single_subject: { en: '{{ app_title }}: Transfer of responsability',
                              de: '{{ app_title }}: Űbertragung der Verantwortlichkeit' },
      email_single_subject_vars: ['app_title'],
      email_summary: { en: 'TBD', de: 'TBD' },
      email_summary_vars: [],
      email_summary_subject: { en: '{{ app_title }}: Summary: Transfer of responsability',
                               de: '{{ app_title }}: Zusammenfassung: Űbertragung der Verantwortlichkeit' },
      email_summary_subject_vars: ['app_title']
    )
  end

  def down
    MigrationNotificationTemplate.find('transfer_responsibility').destroy!
  end
end
