class CreatePermissionPresets < ActiveRecord::Migration[4.2]
  include Madek::Constants
  include Madek::MigrationHelper

  def change
    create_table :permission_presets, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :name
      t.float :position
      MADEK_V2_PERMISSION_ACTIONS.each do |action|
        t.boolean action, null: false, default: false
      end
    end

    # this is mainly to provide a hard condition on uniqueness
    add_index :permission_presets, [:view, :edit, :download, :manage], unique: true, name: :idx_bools_unique
    add_index :permission_presets, :name, unique: true, name: :idx_name_unique
  end
end
