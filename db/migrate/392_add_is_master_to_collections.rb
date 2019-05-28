class AddIsMasterToCollections < ActiveRecord::Migration[5.2]
  class MigrationCollection < ActiveRecord::Base
    self.table_name = :collections

    belongs_to :workflow, optional: true
  end

  def change
    add_column :collections, :is_master, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        MigrationCollection.joins(:workflow).order(:created_at).group(:id, :workflow_id).each do |collection|
          collection.update_column(:is_master, true)
        end
      end
    end
  end
end
