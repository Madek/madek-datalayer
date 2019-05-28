class CreateWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :workflows, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.string :name, null: false
      t.references :user, foreign_key: true, type: :uuid, null: false
      t.boolean :is_active, default: true, null: false
    end
  end
end
