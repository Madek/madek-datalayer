class CreateCopyrights < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :copyrights, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.boolean :is_default, default: false
      t.boolean :is_custom, default: false

      t.string :label
      t.index :label, unique: true

      t.uuid :parent_id
      t.string :usage
      t.string :url

      t.float :position
    end

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE copyrights ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES copyrights (id)'
      end
    end
  end
end
