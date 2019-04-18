class RemoveIsExtensibleFromMetaKeys < ActiveRecord::Migration[4.2]
  def change
    remove_column :meta_keys, :is_extensible, :bool, default: false
  end
end
