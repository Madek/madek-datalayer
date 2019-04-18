class CreateJoinTableMetaDataRole < ActiveRecord::Migration[4.2]
  def change
    create_table :meta_data_roles, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.belongs_to :meta_datum, type: :uuid, index: true
      t.belongs_to :person, type: :uuid, index:true, null: false
      t.belongs_to :role, type: :uuid, index: true
      t.uuid :created_by_id

      t.integer :position, default: 0, null: false
      t.index :position
    end

    add_foreign_key :meta_data_roles, :users, column: :created_by_id
  end
end
