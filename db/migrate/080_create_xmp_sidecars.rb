class CreateXmpSidecars < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def up
    create_table :xmp_sidecars, id: :uuid do |t|
      t.uuid :media_entry_id, null: false
      t.uuid :user_id
      t.string :filename
      t.jsonb :meta_data, null: false, default: {}
      t.text :xml, null: false
    end
    add_auto_timestamps :xmp_sidecars, updated_at: false, null: false
    add_foreign_key :xmp_sidecars, :media_entries, on_delete: :cascade
    add_foreign_key :xmp_sidecars, :users, on_delete: :nullify
    add_index :xmp_sidecars, :media_entry_id

    execute <<-SQL.strip_heredoc
      CREATE TRIGGER xmp_sidecars_audit_change
      AFTER INSERT OR DELETE OR UPDATE ON xmp_sidecars
      FOR EACH ROW EXECUTE FUNCTION audit_change();
    SQL
  end

  def down
    drop_table :xmp_sidecars
  end
end
