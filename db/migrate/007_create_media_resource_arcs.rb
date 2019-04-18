class CreateMediaResourceArcs < ActiveRecord::Migration[4.2]

  def change
    create_table :media_resource_arcs, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'

      t.uuid :parent_id, null: false
      t.uuid :child_id, null: false

      t.boolean :highlight, default: false
      t.boolean :cover

    end

    add_index :media_resource_arcs, [:parent_id, :child_id], unique: true
    add_index :media_resource_arcs, [:child_id, :parent_id], unique: true
    add_index :media_resource_arcs, :cover
    add_index :media_resource_arcs, :parent_id
    add_index :media_resource_arcs, :child_id

    add_foreign_key :media_resource_arcs, :media_resources, column: :child_id, on_delete: :cascade
    add_foreign_key :media_resource_arcs, :media_resources, column: :parent_id, on_delete: :cascade

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE media_resource_arcs  ADD CHECK (parent_id <> child_id);'
      end
    end
  end
end
