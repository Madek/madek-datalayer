class UsersOnDeleteCascadeEmails < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :emails, :users
    remove_foreign_key :emails, :delegations
    add_foreign_key :emails, :users, on_delete: :cascade, name: "emails_user_id_fk"
    add_foreign_key :emails, :delegations, on_delete: :cascade, name: "emails_delegation_id_fk"
  end
end

