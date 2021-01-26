class CreateJoinTableDelegationWorkflow < ActiveRecord::Migration[5.2]
  def change
    create_join_table :delegations, :workflows, column_options: { type: :uuid } do |t|
      t.index [:delegation_id, :workflow_id], unique: true
      t.index [:workflow_id, :delegation_id]
    end
  end
end
