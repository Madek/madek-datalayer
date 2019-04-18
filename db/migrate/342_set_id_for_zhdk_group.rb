class SetIdForZhdkGroup < ActiveRecord::Migration[4.2]
  def change

    [:collection_group_permissions, :filter_set_group_permissions,
     :groups_users, :media_entry_group_permissions,
     :vocabulary_group_permissions].each do |ftable|
       remove_foreign_key ftable, :groups
       add_foreign_key ftable, :groups, on_delete: :cascade, on_update: :cascade
     end

    # the new id is UUIDTools::UUID.sha1_create Madek::Constants::MADEK_UUID_NS, "ZHdK users"
    execute <<-SQL.strip_heredoc
      UPDATE groups SET id = 'efbfca9f-4191-5d27-8c94-618be5a125f5'
        WHERE name = 'ZHdK (Zürcher Hochschule der Künste)';
    SQL

  end
end
