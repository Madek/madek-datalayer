class AddConfigurationToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :configuration, :jsonb, default: {}
  end
end
