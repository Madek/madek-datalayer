class CreateJoinTableUserWorkflow < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :workflows, column_options: { type: :uuid } do |t|
      t.index [:user_id, :workflow_id]
      t.index [:workflow_id, :user_id]
    end
  end
end
