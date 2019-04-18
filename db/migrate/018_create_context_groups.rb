class CreateContextGroups < ActiveRecord::Migration[4.2]

  def change
    create_table :context_groups, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :name
      t.index :name, unique: true

      t.integer :position, null: false
      t.index :position
    end
  end

end
