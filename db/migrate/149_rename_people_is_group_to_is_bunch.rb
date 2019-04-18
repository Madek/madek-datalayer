class RenamePeopleIsGroupToIsBunch < ActiveRecord::Migration[4.2]
  def change
    rename_column :people, :is_group, :is_bunch
  end
end
