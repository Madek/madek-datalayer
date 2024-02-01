class MigrateInstitution < ActiveRecord::Migration[6.1]

  ZHDK_USERS_GROUP_ID = 'efbfca9f-4191-5d27-8c94-618be5a125f5'

  def up

    # users
    #
    execute <<-SQL.strip_heredoc

      DROP TRIGGER update_updated_at_column_of_users ON users;

      UPDATE users SET institution = 'zhdk.ch'
      WHERE login IS NOT NULL
      AND institution = 'local'
      AND email ILIKE '%@zhdk.ch';

      CREATE TRIGGER update_updated_at_column_of_users BEFORE UPDATE ON
      public.users FOR EACH ROW WHEN ((old.* IS DISTINCT FROM new.*)) EXECUTE
      FUNCTION public.update_updated_at_column();


    SQL


    # people

    remove_index :people, name: 'index_people_on_institutional_id'

    add_column :people, :institution, :text, null: false, default: 'local'

    execute <<-SQL.strip_heredoc

      UPDATE people
        SET institution = 'zhdk.ch'
      FROM users
        WHERE users.person_id = people.id
        AND people.institution = 'local'
        AND users.institution = 'zhdk.ch'

    SQL

    add_index :people, [:institution, :institutional_id], unique: true


    # groups

    remove_index :groups, name: 'index_groups_on_institutional_name'

    add_index :groups, [:institution, :institutional_name], unique: true

    execute <<-SQL.strip_heredoc

      UPDATE groups SET institution = 'zhdk.ch'
      WHERE id = '#{ZHDK_USERS_GROUP_ID}';

      UPDATE groups SET institution = 'zhdk.ch'
      WHERE institution = 'local'
      AND type = 'InstitutionalGroup'
      AND EXISTS (SELECT True FROM groups WHERE id = '#{ZHDK_USERS_GROUP_ID}');

    SQL

  end

end

