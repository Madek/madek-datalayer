class RemoveIsExtensibleFromMetaKeys < ActiveRecord::Migration
  def change
    remove_column :meta_keys, :is_extensible, :bool, default: false
  end
end
