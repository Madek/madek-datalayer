class CreateMetaData < ActiveRecord::Migration[4.2]

  def change
    create_table :meta_data, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.string :meta_key_id, null: false
      t.index :meta_key_id

      t.index [:media_resource_id, :meta_key_id], unique: :true

      t.string :type
      t.index :type

      t.text :string

      t.uuid :copyright_id
    end

    add_foreign_key :meta_data, :media_resources, on_delete: :cascade
    add_foreign_key :meta_data, :meta_keys, on_delete: :cascade

    add_foreign_key :meta_data, :copyrights
  end

end
