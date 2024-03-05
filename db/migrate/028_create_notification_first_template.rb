class CreateNotificationFirstTemplate < ActiveRecord::Migration[6.1]
  include Madek::MigrationHelper

  class MigrationNotificationTemplate < ActiveRecord::Base
    self.table_name = 'notification_templates'
  end

  def up
    MigrationNotificationTemplate.create(
      label: 'responsibility_transfer',
      description: 'notification to be sent when responsibility for an entry or set is transfered to another user',
      ui_en: 'Responsibility for an entry or set has been transfered to you.',
      ui_de: 'Es wurde dir Verantwortung für einen Medieneintrag oder Set übertragen.',
      email_single_en: 'Responsibility for an entry or set has been transfered to you.',
      email_single_de: 'Es wurde dir Verantwortung für einen Medieneintrag oder Set übertragen.',
      email_summary_en: 'Responsibility for the following entries and/or sets have been transfered to you:',
      email_summary_de: 'Es wurde dir Verantwortung für folgende Medieneinträge und/oder Sets übertragen:'
    )
  end
end
