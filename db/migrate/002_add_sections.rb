class AddSections < ActiveRecord::Migration[6.0]
  include Madek::MigrationHelper

  def change
    add_reference :app_settings, :section_meta_key, foreign_key: { to_table: :meta_keys }, type: :string
    
    create_table :sections, id: :uuid do |t|
      t.uuid :keyword_id, null: false
      t.string :color
      t.uuid :index_collection_id
      t.hstore :labels, default: {}, null: false
    end

    add_foreign_key :sections, :keywords
    add_index :sections, :keyword_id, unique: true
    add_foreign_key :sections, :collections, column: :index_collection_id

    reversible do |dir|
      dir.up do
        add_column(:sections, :created_at, 'timestamp with time zone', null: false)
        add_column(:sections, :updated_at, 'timestamp with time zone', null: false)
        set_timestamps_defaults :sections
      end
    end

  end
end
