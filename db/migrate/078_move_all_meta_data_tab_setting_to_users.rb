class MoveAllMetaDataTabSettingToUsers < ActiveRecord::Migration[7.2]
  GROUP_NAME = "Erweiterte Funktionen Medienarchiv"

  def up
    group_id = connection.select_value(<<~SQL)
      SELECT edit_meta_data_power_users_group_id
      FROM app_settings
      ORDER BY id
      LIMIT 1
    SQL

    if group_id
      enable_preference_for_group_members!(group_id)
    else
      enable_preference_for_all_users!
    end

    if foreign_key_exists?(:app_settings, column: :edit_meta_data_power_users_group_id)
      remove_foreign_key :app_settings, column: :edit_meta_data_power_users_group_id
    end

    if column_exists?(:app_settings, :edit_meta_data_power_users_group_id)
      remove_column :app_settings, :edit_meta_data_power_users_group_id
    end

    dissolve_groups!([group_id].compact + named_group_ids)
  end

  def down
    add_column :app_settings, :edit_meta_data_power_users_group_id, :uuid
    add_foreign_key(
      :app_settings,
      :groups,
      column: :edit_meta_data_power_users_group_id)
  end

  private

  def enable_preference_for_group_members!(group_id)
    execute <<~SQL
      UPDATE users
      SET settings = #{normalized_settings_sql} ||
        '{"show_all_data_tab_in_edit_mode": true}'::jsonb
      WHERE EXISTS (
        SELECT 1
        FROM groups_users
        WHERE groups_users.user_id = users.id
          AND groups_users.group_id = #{connection.quote(group_id)}
      );
    SQL
  end

  def enable_preference_for_all_users!
    execute <<~SQL
      UPDATE users
      SET settings = #{normalized_settings_sql} ||
        '{"show_all_data_tab_in_edit_mode": true}'::jsonb;
    SQL
  end

  def normalized_settings_sql
    <<~SQL.squish
      CASE
        WHEN jsonb_typeof(settings) = 'object' THEN settings
        ELSE '{}'::jsonb
      END
    SQL
  end

  def named_group_ids
    connection.select_values(<<~SQL)
      SELECT id
      FROM groups
      WHERE name = #{connection.quote(GROUP_NAME)}
    SQL
  end

  def dissolve_groups!(group_ids)
    group_ids.uniq.each do |id|
      quoted_id = connection.quote(id)
      execute <<~SQL
        DELETE FROM delegations_groups
        WHERE group_id = #{quoted_id};

        DELETE FROM groups
        WHERE id = #{quoted_id};
      SQL
    end
  end
end
