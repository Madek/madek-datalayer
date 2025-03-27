class AddBannerMessageSetting < ActiveRecord::Migration[7.2]
  def change
    add_column :app_settings, :banner_messages, :hstore, default: {}, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE app_settings
          SET banner_messages = hstore(ARRAY['en', NULL, 'de', NULL]);
        SQL
      end
    end
  end
end
