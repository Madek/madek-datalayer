class CreateGroups < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :groups, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.integer :previous_id

      t.string :name
      t.index :name

      t.string :institutional_group_id
      t.index :institutional_group_id

      t.string :institutional_group_name
      t.index :institutional_group_name

      t.string :type, default: 'Group', null: false
      t.index :type

      t.text :searchable, default: '', null: false

      t.integer :users_count, default: 0

    end

    reversible do |dir|
      dir.up do
        create_trgm_index :groups, :searchable
        create_text_index :groups, :searchable
      end
    end
  end

end
