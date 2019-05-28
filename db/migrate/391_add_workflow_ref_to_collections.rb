class AddWorkflowRefToCollections < ActiveRecord::Migration[5.2]
  def change
    add_reference :collections, :workflow, foreign_key: true, null: true, type: :uuid
  end
end
