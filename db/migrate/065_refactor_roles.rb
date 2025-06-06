class RefactorRoles < ActiveRecord::Migration[7.2]
  def up
    add_column :meta_data_people, :role_id, :uuid
    add_foreign_key :meta_data_people, :roles, column: :role_id
  end
end
