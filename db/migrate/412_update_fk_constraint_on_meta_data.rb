class UpdateFkConstraintOnMetaData < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :meta_data, column: :meta_key_id, on_update: :cascade, on_delete: :cascade
    add_foreign_key :meta_data, :meta_keys, on_update: :cascade
  end
end
