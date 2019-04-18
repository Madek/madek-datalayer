class AutoUpdateSearchables < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    auto_update_searchable :people, [:first_name, :last_name, :pseudonym]
    auto_update_searchable :groups, [:name, :institutional_group_name]
    auto_update_searchable :users, [:login, :email]
    auto_update_searchable :licenses, [:label, :usage, :url]
  end
end
