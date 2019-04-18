class MigrateApiApplication < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  class ApiApplication < ActiveRecord::Base
    self.table_name = 'applications'
  end


  def change

    create_table :api_clients, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.uuid :user_id, null: false
      t.string :login, null: false
      t.index :login, unique: true
      t.text :description
      t.string :password_digest
      t.timestamps null: false
    end
    set_timestamps_defaults :api_clients

    ApiApplication.all.each do |api_app|
      ApiClient.create! login: api_app.id,
        user_id: api_app.user_id, description: api_app.description,
        password: api_app.secret
    end

    add_foreign_key :api_clients, :users

    execute %q< ALTER TABLE api_clients ADD CONSTRAINT name_format CHECK (login~ '^[a-z][a-z0-9\-\_]+$'); >

    execute %{

      CREATE OR REPLACE FUNCTION check_users_apiclients_login_uniqueness()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (EXISTS (SELECT 1 FROM users, api_clients
              WHERE api_clients.login = users.login
              AND api_clients.login = NEW.login)) THEN
          RAISE EXCEPTION 'The login % over users and api_clients must be unique.', NEW.login;
        END IF;
        RETURN NEW;
      END;
      $$ language 'plpgsql'; }

    execute %[ CREATE CONSTRAINT TRIGGER trigger_check_users_apiclients_login_uniqueness_on_users
                AFTER INSERT OR UPDATE
                ON users
                INITIALLY DEFERRED
                FOR EACH ROW
                EXECUTE PROCEDURE check_users_apiclients_login_uniqueness()  ]

    execute %[ CREATE CONSTRAINT TRIGGER trigger_check_users_apiclients_login_uniqueness_on_apiclients
                AFTER INSERT OR UPDATE
                ON api_clients
                INITIALLY DEFERRED
                FOR EACH ROW
                EXECUTE PROCEDURE check_users_apiclients_login_uniqueness()  ]

  end
end
