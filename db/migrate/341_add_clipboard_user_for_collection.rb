class AddClipboardUserForCollection < ActiveRecord::Migration[4.2]
  def up
    add_column :collections, :clipboard_user_id, :string, null: true, default: nil
    add_index :collections, :clipboard_user_id, unique: true
  end
end
