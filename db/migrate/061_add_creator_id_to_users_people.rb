class AddCreatorIdToUsersPeople < ActiveRecord::Migration[7.2]
  def change
    [:users, :people].each do |table|
      add_column table, :creator_id, :uuid
      add_foreign_key table, :users, column: :creator_id, on_delete: :nullify

      add_column table, :updator_id, :uuid
      add_foreign_key table, :users, column: :updator_id, on_delete: :nullify
    end
  end
end
