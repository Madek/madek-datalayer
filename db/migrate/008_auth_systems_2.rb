class AuthSystems2 < ActiveRecord::Migration[6.0]
  def up

    execute <<-SQL.strip_heredoc

      ALTER TABLE auth_systems DROP COLUMN IF EXISTS create_account_email_match;
      ALTER TABLE auth_systems DROP COLUMN IF EXISTS create_account_enabled;

      ALTER TABLE auth_systems ADD COLUMN email_or_login_match text;

      ALTER TABLE auth_systems ADD COLUMN manage_accounts boolean DEFAULT false NOT NULL; 

      ALTER TABLE auth_systems ADD COLUMN managed_domain text; 

      ALTER TABLE users ADD COLUMN institution text DEFAULT 'local' NOT NULL;

      -- remove unique
      DROP INDEX index_users_on_institutional_id;
      CREATE INDEX index_users_on_institutional_id ON users (institutional_id);

      CREATE UNIQUE INDEX users_on_institution_idx ON users 
        (institution, institutional_id);


      ALTER TABLE groups ADD COLUMN institution text DEFAULT 'local' NOT NULL;

      CREATE UNIQUE INDEX groups_on_institution_idx ON groups 
        (institution, institutional_id);

      -- remove unique
      DROP INDEX index_groups_on_institutional_id;
      CREATE INDEX index_groups_on_institutional_id ON groups (institutional_id);

      ALTER TABLE auth_systems DROP CONSTRAINT allowed_type;
      ALTER TABLE auth_systems ADD CONSTRAINT allowed_type
        CHECK (type IN ('password', 'external', 'legacy'));

      ALTER TABLE auth_systems DROP CONSTRAINT password_special;

      ALTER TABLE auth_systems ADD CONSTRAINT password_special 
        CHECK (
          (type = 'password' AND id = 'password') 
          OR 
          (type <> 'password' AND id <> 'password'));

      UPDATE auth_systems SET 
          email_or_login_match = '^.+@zhdk\.ch$',
          enabled = true,
          external_sign_in_url = '/login/zhdk',
          priority = 10,
          send_email = false,
          send_login = false,
          type = 'legacy'
        WHERE id = 'zhdk_agw';

      INSERT INTO auth_systems_groups (auth_system_id, group_id)
        SELECT auth_systems.id, 'efbfca9f-4191-5d27-8c94-618be5a125f5'
        FROM auth_systems 
        WHERE auth_systems.id = 'zhdk_agw'
        ON CONFLICT DO NOTHING ;

    SQL

  end


  def down
  end

end

