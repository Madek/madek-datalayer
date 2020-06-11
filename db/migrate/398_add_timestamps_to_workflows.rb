class AddTimestampsToWorkflows < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  class MigrationWorkflow < ActiveRecord::Base
    self.table_name = :workflows
  end

  def change
    add_auto_timestamps :workflows
    MigrationWorkflow.reset_column_information

    MigrationWorkflow.all.each do |wf|
      wf.update_attributes!(created_at: DateTime.now, updated_at: DateTime.now)
    end
  end
end
