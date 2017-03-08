class CascadeUpdateMetaKeyId < ActiveRecord::Migration
  def change
    %w(context_keys keywords io_mappings meta_data).each do |ftable|
      remove_foreign_key ftable, :meta_keys
      add_foreign_key ftable, :meta_keys, on_delete: :cascade, on_update: :cascade
    end
  end
end
