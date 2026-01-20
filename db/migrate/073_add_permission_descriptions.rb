class AddPermissionDescriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :app_settings, :permission_public_descriptions, :hstore, default: {}, null: false
    add_column :api_clients, :permission_descriptions, :hstore, default: {}, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE app_settings
          SET permission_public_descriptions = hstore(ARRAY['en', NULL, 'de', NULL]);
        SQL
      end
    end
  end
end
