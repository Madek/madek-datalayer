class CreateTableSmtpSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :smtp_settings do |t|
      t.boolean :is_enabled, null: false, default: false
      t.text :host_address, null: false, default: 'localhost'
      t.text :authentication_type, default: 'plain'
      t.text :default_from_address, null: false, default: 'noreply'
      t.text :domain
      t.boolean :enable_starttls_auto, null: false, default: false
      t.text :openssl_verify_mode, null: false, default: 'none'
      t.text :password
      t.integer :port, null: false, default: 25
      t.text :sender_address
      t.text :username
    end

    add_column(:smtp_settings, :created_at, :timestamptz, null: true)
    add_column(:smtp_settings, :updated_at, :timestamptz, null: true)

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE smtp_settings
          ALTER COLUMN id SET DEFAULT 0,
          ADD CONSTRAINT oneandonly CHECK ( id = 0 );
        SQL
      end
    end
  end
end
