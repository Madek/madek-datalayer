class CreateRoles < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')

    create_table :roles, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.hstore :labels, default: '', null: false
      t.references :meta_key, type: :string, foreign_key: true, index: true, null: false
      t.uuid :creator_id, index: true
      t.timestamps null: false
    end
    set_timestamps_defaults :roles

    add_index :roles, [:meta_key_id, :labels], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE roles
          ADD CONSTRAINT labels_non_blank
          CHECK (array_to_string(avals(labels), '') !~ '^\s*$'),
          ADD FOREIGN KEY (creator_id)
          REFERENCES users(id),
          ALTER COLUMN creator_id SET NOT NULL
        SQL
      end
    end
  end
end
