class SystemAdmins < ActiveRecord::Migration[5.2]

  def change

    create_table :system_admins, id: :uuid do |t|
      t.uuid :user_id, null: false
    end
    add_foreign_key :system_admins, :users, on_delete: :cascade





  end

end
