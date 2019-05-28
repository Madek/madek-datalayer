class CreateWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :workflows, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :name, null: false
      t.uuid :creator_id, null: false
      t.boolean :is_active, default: true, null: false
    end

    add_foreign_key :workflows, :users, column: :creator_id
  end
end
